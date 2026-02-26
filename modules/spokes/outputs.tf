output "bucket_arn" {
  description = "The ARN of the S3 bucket used to store the cloudformation templates"
  value       = format("arn:aws:s3:::%s", var.cloudformation_bucket_name)
}

output "bucket_name" {
  description = "The name of the S3 bucket used to store the cloudformation templates"
  value       = var.cloudformation_bucket_name
}

output "stackset_arn" {
  description = "The ARN of the stackset deployed to the spoke accounts"
  value       = aws_cloudformation_stack_set.spokes.id
}
