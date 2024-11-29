
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

output "cloudformation_scheduler_arn" {
  description = "The ARN for the scheduler cloudformation scheduler template"
  value       = aws_s3_object.instance_scheduler_template.arn
}

output "cloudformation_spoke_arn" {
  description = "The ARN for the spoke cloudformation scheduler template"
  value       = aws_s3_object.instance_scheduler_template_remote.arn
}

output "cloudformation_spoke_url" {
  description = "The URL for the spoke cloudformation scheduler template"
  value       = format("https://%s.s3.%s.amazonaws.com/%s", module.s3_bucket.s3_bucket_id, local.region, aws_s3_object.instance_scheduler_template_remote.key)
}

output "cloudformation_scheduler_url" {
  description = "The URL for the scheduler cloudformation scheduler template"
  value       = format("https://%s.s3.%s.amazonaws.com/%s", module.s3_bucket.s3_bucket_id, local.region, aws_s3_object.instance_scheduler_template.key)
}
