
output "resources_in_scope" {
  description = "A map of the resources which are going to be tagged"
  value       = local.resources_in_scope_all
}

output "lambda_function_arns" {
  description = "The Lambda function resources"
  value       = [for k in module.lambda_function : k.lambda_function_arn]
}

output "lambda_iam_role_arns" {
  description = "The IAM role ARNs for the Lambda functions"
  value       = [for k in module.lambda_function : k.lambda_role_arn]
}

output "lambda_iam_role_names" {
  description = "A list of the IAM role names for the Lambda functions"
  value       = [for k in module.lambda_function : k.lambda_role_name]
}

output "lambda_cloudwatch_logs_group_names" {
  description = "A list of the CloudWatch log group names for the Lambda functions"
  value       = [for k in module.lambda_function : k.lambda_cloudwatch_log_group_name]
}

output "lambda_cloudwatch_logs_group_arns" {
  description = "A list of the CloudWatch log group ARNs for the Lambda functions"
  value       = [for k in module.lambda_function : k.lambda_cloudwatch_log_group_arn]
}
