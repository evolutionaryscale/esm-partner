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