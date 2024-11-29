
variable "cloudformation_hub_stack_name" {
  description = "The name of the cloudformation stack in the hub account"
  type        = string
  default     = "lza-instance-scheduler-hub"
}

variable "cloudformation_hub_stack_capabilities" {
  description = "The capabilities required for the cloudformation stack in the hub account"
  type        = list(string)
  default     = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
}

variable "cloudformation_bucket_name" {
  description = "The name of the S3 bucket used to store the cloudformation templates"
  type        = string
  default     = "lza-instance-scheduler-templates"
}

variable "enable_organizations" {
  description = "Whether the instance scheduler should integrate with AWS Organizations"
  type        = bool
  default     = true
}

variable "enable_organizational_bucket" {
  description = "Indicate we should allow everyone in the organizations access to the cloudformation bucket"
  type        = bool
  default     = false
}

variable "organizational_id" {
  description = "The AWS Organization ID used in conjunction with the organizational bucket"
  type        = string
  default     = ""
}

variable "enable_ssm_maintenance_windows" {
  description = "Whether EC2 instances should be managed by SSM Maintenance Windows"
  type        = bool
  default     = false
}

variable "enable_scheduler" {
  description = "Whether the instance scheduler should be enabled"
  type        = bool
  default     = true
}

variable "enable_ec2_scheduler" {
  description = "Whether EC2 instances should under the remit of the scheduler"
  type        = bool
  default     = true
}

variable "enable_rds_scheduler" {
  description = "Whether RDS instances should under the remit of the scheduler"
  type        = bool
  default     = true
}

variable "enable_rds_cluster_scheduler" {
  description = "Whether RDS clusters should under the remit of the scheduler"
  type        = bool
  default     = true
}

variable "enable_rds_snapshot" {
  description = "Whether RDS instances should have snapshots created on stop"
  type        = bool
  default     = false
}

variable "enable_hub_account_scheduler" {
  description = "Whether the hub account should be under the remit of the scheduler"
  type        = bool
  default     = true
}

variable "enable_neptune_scheduler" {
  description = "Whether Neptune clusters should under the remit of the scheduler"
  type        = bool
  default     = true
}

variable "enable_docdb_scheduler" {
  description = "Whether DocumentDB clusters should under the remit of the scheduler"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_dashboard" {
  description = "Whether a CloudWatch dashboard used to monitor the scheduler should be created"
  type        = bool
  default     = false
}

variable "enable_debug" {
  description = "Whether debug logging should be enabled for the instance scheduler"
  type        = bool
  default     = false
}

variable "enable_asg_scheduler" {
  description = "Whether AutoScaling Groups should under the remit of the scheduler"
  type        = bool
  default     = true
}

variable "scheduler_start_tags" {
  description = "The tags used to identify the resources that should be started"
  type        = string
  default     = "InstanceScheduler-LastAction=Started By {scheduler} {year}/{month}/{day} {hour}:{minute}{timezone},>"
}

variable "scheduler_stop_tags" {
  description = "The tags used to identify the resources that should be stopped"
  type        = string
  default     = "InstanceScheduler-LastAction=Stopped By {scheduler} {year}/{month}/{day} {hour}:{minute}{timezone},>"
}

variable "scheduler_tag_name" {
  description = "The tag name used to identify the resources that should be scheduled"
  type        = string
}

variable "scheduler_frequency" {
  description = "The frequency at which the instance scheduler should run in minutes"
  type        = number
  default     = 60

  validation {
    condition     = contains([1, 2, 5, 10, 15, 30, 60], var.scheduler_frequency)
    error_message = "The scheduler frequency must be 1, 2, 5, 10, 15, 30, or 60"
  }
}

variable "scheduler_timezone" {
  description = "The default timezone for the instance scheduler"
  type        = string
  default     = "UTC"
}

variable "scheduler_asg_tag_key" {
  description = "The tag key used to identify AutoScaling Groups that should be scheduled"
  type        = string
  default     = "scheduled"
}

variable "scheduler_asg_rule_prefix" {
  description = "The prefix used to identify the AutoScaling Group scheduled actions"
  type        = string
  default     = "is-"
}

variable "scheduler_organizations_ids" {
  description = "A list of organizations ids that are permitted to use the scheduler"
  type        = list(string)
  default     = []
}

variable "scheduler_regions" {
  description = "The regions in which the instance scheduler should operate"
  type        = list(string)
  default     = []
}

variable "scheduler_log_group_retention" {
  description = "The retention period for the instance scheduler log group"
  type        = string
  default     = "7"
}

variable "kms_key_arns" {
  description = "The KMS key ARNs used to encrypt the instance scheduler data"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}
