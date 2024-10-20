
output "scheduler_dynamodb_table" {
  description = "The DynamoDB table to use for the scheduler"
  value       = try(aws_cloudformation_stack.hub.outputs["ConfigurationTable"], null)
}

output "scheduler_role_arn" {
  description = "The role arn of the scheduler"
  value       = try(aws_cloudformation_stack.hub.outputs["SchedulerRoleArn"], null)
}

output "scheduler_sns_issue_topic_arn" {
  description = "The SNS topic to use for the scheduler"
  value       = try(aws_cloudformation_stack.hub.outputs["IssueSnsTopicArn"], null)
}

output "account_id" {
  description = "The account id of the scheduler"
  value       = local.account_id
}

