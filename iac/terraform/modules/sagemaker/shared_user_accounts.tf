# This module creates a shared service account for accessing SageMaker endpoints.
# It includes IAM user creation, policy attachment, and access key generation.
#
# This module is designed to be used in conjunction with the main SageMaker module.
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
}

resource "aws_iam_user" "shared_service_user" {
  # count = var.enable_shared_service_account ? 1 : 0

  name = local.shared_service_account_final_name
  tags = var.tags
}

resource "aws_iam_policy" "shared_invoke_policy" {
  # count       = var.enable_shared_service_account ? 1 : 0
  name        = "${var.iam_role_name_prefix}-shared-invoke-policy-${var.environment}"
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
  # count      = var.enable_shared_service_account ? 1 : 0
  # user       = aws_iam_user.shared_service_user[0].name
  user = aws_iam_user.shared_service_user.name
  # policy_arn = aws_iam_policy.shared_invoke_policy[0].arn
  policy_arn = aws_iam_policy.shared_invoke_policy.arn
}

resource "aws_iam_access_key" "shared_service_access_key" {
  # count = var.enable_shared_service_account ? 1 : 0
  # user  = aws_iam_user.shared_service_user[0].name
  user = aws_iam_user.shared_service_user.name
}
