# These data sources provide information about the environment this
# terraform is running in -- it's how we can know which account, region,
# and partition (ie, commercial AWS vs GovCloud) we're in.

data "aws_caller_identity" "current" {}

output "caller_account_id" {
  description = "The AWS account ID in which Terraform is running."
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "The ARN of the AWS identity running Terraform."
  value       = data.aws_caller_identity.current.arn
}

output "caller_user_id" {
  description = "The user ID of the AWS identity running Terraform."
  value       = data.aws_caller_identity.current.user_id
}
