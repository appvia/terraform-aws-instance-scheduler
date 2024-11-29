
output "cloudformation_scheduler_arn" {
  description = "The ARN for the scheduler cloudformation scheduler template"
  value       = module.scheduler.cloudformation_scheduler_arn
}

output "cloudformation_spoke_arn" {
  description = "The ARN for the spoke cloudformation scheduler template"
  value       = module.scheduler.cloudformation_spoke_arn
}

output "cloudformation_spoke_url" {
  description = "The URL for the spoke cloudformation scheduler template"
  value       = module.scheduler.cloudformation_spoke_url
}

output "cloudformation_scheduler_url" {
  description = "The URL for the scheduler cloudformation scheduler template"
  value       = module.scheduler.cloudformation_scheduler_url
}
