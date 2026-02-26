output "bucket_arn" {
  description = "The ARN of the S3 bucket used to store the cloudformation templates"
  value       = format("arn:aws:s3:::%s", var.cloudformation_bucket_name)
}

output "bucket_name" {
  description = "The name of the S3 bucket used to store the cloudformation templates"
  value       = var.cloudformation_bucket_name
}

output "cloudformation_arn" {
  description = "The ARN of the cloudformation stack deployed to the spoke account"
  value       = aws_cloudformation_stack.spoke.id
}
