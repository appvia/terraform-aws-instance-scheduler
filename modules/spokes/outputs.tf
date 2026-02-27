output "stackset_arn" {
  description = "The ARN of the stackset deployed to the spoke accounts"
  value       = aws_cloudformation_stack_set.spokes.id
}
