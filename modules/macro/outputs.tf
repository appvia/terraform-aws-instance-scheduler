output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.current.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.current.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.current.arn
}

output "cloudformation_stack_name" {
  description = "Name of the CloudFormation stack containing the macro"
  value       = aws_cloudformation_stack.current.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.current.name
}
