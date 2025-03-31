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
  description = "The name of the shared service IAM user, if created."
  value       = var.enable_shared_service_account ? aws_iam_user.shared_service_user.name : ""
}

output "shared_service_user_access_key_id" {
  description = "The access key ID for the shared service IAM user, if created."
  value       = var.enable_shared_service_account ? aws_iam_access_key.shared_service_access_key.id : ""
}

output "shared_service_user_secret_access_key" {
  description = "The secret access key for the shared service IAM user, if created."
  value       = var.enable_shared_service_account ? aws_iam_access_key.shared_service_access_key.secret : ""
  sensitive   = true
}
