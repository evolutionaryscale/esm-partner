# This config creates a shared service account for accessing SageMaker endpoints.
# It includes IAM user creation, policy attachment, and access key generation.
#
# This config is designed to be used in conjunction with the main SageMaker module.
# It is assumed that the IAM role for SageMaker execution and the models are
# already defined in the main module.
#
# The shared service account is optional and can be enabled or disabled via
# the `enable_shared_service_account` variable. If enabled, a user will be created
# with the specified name or a default name based on the provided prefix and
# environment. The user will be granted permissions to invoke SageMaker endpoints.
#
# Note: Be cautious when outputting sensitive information like access keys.
# Ensure that the output is handled securely and not exposed in logs or
# version control systems.

locals {
  default_shared_service_account_name = "${var.iam_role_name_prefix}-shared-invoke-${var.environment}"
  shared_service_account_final_name   = var.shared_service_account_name != "" ? var.shared_service_account_name : local.default_shared_service_account_name

  # Build a map of shared accounts to create if enabled; otherwise an empty map.
  shared_accounts_map = var.enable_shared_service_account ? {
    (local.shared_service_account_final_name) = {
      name = local.shared_service_account_final_name
    }
  } : {}
}

resource "aws_iam_user" "shared_service_user" {
  for_each = local.shared_accounts_map

  name = each.value.name
  tags = var.tags
}

resource "aws_iam_policy" "shared_invoke_policy" {
  for_each = local.shared_accounts_map

  name        = "${var.iam_role_name_prefix}-shared-invoke-policy-${var.environment}-${each.key}"
  description = "Policy to allow invoking SageMaker endpoints"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint"
        ],
        Resource = "*" // Adjust scope as needed.
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "shared_invoke_policy_attachment" {
  for_each = local.shared_accounts_map

  user       = aws_iam_user.shared_service_user[each.key].name
  policy_arn = aws_iam_policy.shared_invoke_policy[each.key].arn
}

resource "aws_iam_access_key" "shared_service_access_key" {
  for_each = local.shared_accounts_map

  user = aws_iam_user.shared_service_user[each.key].name
}
