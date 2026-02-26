output "bucket_arn" {
  description = "The ARN of the S3 bucket used to store the cloudformation templates"
  value       = module.s3_bucket.s3_bucket_arn
}

output "bucket_name" {
  description = "The name of the S3 bucket used to store the cloudformation templates"
  value       = module.s3_bucket.s3_bucket_id
}

output "stackset_arn" {
  description = "The ARN of the stackset deployed to the spoke accounts"
  value       = aws_cloudformation_stack_set.spokes.id
}
