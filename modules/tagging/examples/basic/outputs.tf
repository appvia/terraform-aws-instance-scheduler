
output "resources_in_scope" {
  description = "A map of the resources which are going to be tagged"
  value       = module.tagging_enforcement.resources_in_scope
}

output "lambda_function_arns" {
  description = "List of the Lambda function ARNs"
  value       = module.tagging_enforcement.lambda_function_arns
}

output "lambda_iam_role_arns" {
  description = "List of the IAM role ARNs for the Lambda functions"
  value       = module.tagging_enforcement.lambda_iam_role_arns
}

output "lambda_iam_role_names" {
  description = "List of the IAM role names for the Lambda functions"
  value       = module.tagging_enforcement.lambda_iam_role_names
}

output "lambda_cloudwatch_logs_group_names" {
  description = "List of the CloudWatch log group names for the Lambda functions"
  value       = module.tagging_enforcement.lambda_cloudwatch_logs_group_names
}

output "lambda_cloudwatch_logs_group_arns" {
  description = "List of the CloudWatch log group ARNs for the Lambda functions"
  value       = module.tagging_enforcement.lambda_cloudwatch_logs_group_arns
}
