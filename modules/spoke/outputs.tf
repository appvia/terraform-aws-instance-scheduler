output "cloudformation_arn" {
  description = "The ARN of the cloudformation stack deployed to the spoke account"
  value       = aws_cloudformation_stack.spoke.id
}
