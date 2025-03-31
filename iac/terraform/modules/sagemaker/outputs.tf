output "sagemaker_endpoints" {
  description = "Map of deployed SageMaker endpoint details."
  value = {
    for k, e in aws_sagemaker_endpoint.endpoint :
    k => {
      endpoint_url         = "https://runtime.sagemaker.${var.region}.amazonaws.com/endpoints/${e.name}/invocations"
      endpoint_config_name = e.endpoint_config_name
      endpoint_name        = e.name
      forge_model_name     = local.models_menu[local.final_selected_models[k].selector].forge_model_name
    }
  }
}

output "sagemaker_execution_role" {
  description = "Name of the SageMaker IAM execution role."
  value       = aws_iam_role.sagemaker_execution_role.name
}

# Outputs: Be cautious when outputting secrets.
output "shared_service_user_name" {
  description = "A map of shared service IAM user names, keyed by the shared account name."
  value       = var.enable_shared_service_account ? { for k, u in aws_iam_user.shared_service_user : k => u.name } : {}
}

output "shared_service_user_access_key_id" {
  description = "A map of access key IDs for the shared service IAM users, keyed by the shared account name."
  value       = var.enable_shared_service_account ? { for k, ak in aws_iam_access_key.shared_service_access_key : k => ak.id } : {}
}

output "shared_service_user_secret_access_key" {
  description = "A map of secret access keys for the shared service IAM users, keyed by the shared account name."
  value       = var.enable_shared_service_account ? { for k, ak in aws_iam_access_key.shared_service_access_key : k => ak.secret } : {}
  sensitive   = true
}
