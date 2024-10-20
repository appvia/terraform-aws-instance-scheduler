

variable "lambda_function_name_prefix" {
  description = "The name of the lambda function that will be created"
  type        = string
  default     = "lza-scheduler-tagging"
}

variable "eventbridge_rule_name_prefix" {
  description = "The name of the eventbridge rule that will trigger the lambda function"
  type        = string
  default     = "lza-scheduler-tagging"
}

variable "schedule" {
  description = "The schedule expression that will trigger the lambda function"
  type        = string
  default     = "cron(0/15 * * * ? *)"
}

variable "lambda_memory_size" {
  description = "The amount of memory in MB allocated to the lambda function"
  type        = number
  default     = 128
}

variable "lambda_log_retention" {
  description = "The number of days to retain the logs for the lambda function"
  type        = number
  default     = 7
}

variable "enable_debug" {
  description = "Whether debug logging should be enabled for the lambda function"
  type        = bool
  default     = false
}

variable "lambda_timeout" {
  description = "The amount of time in seconds before the lambda function times out"
  type        = number
  default     = 10
}

variable "lambda_execution_role_name_prefix" {
  description = "The name of the IAM role that will be created for the lambda function"
  type        = string
  default     = "lza-scheduler-tagging"
}

variable "lambda_policy_name_prefix" {
  description = "The name of the IAM policy that will be created for the lambda function"
  type        = string
  default     = "lza-scheduler-tagging"
}

variable "scheduled_tag_name" {
  description = "The name of the tag that will be applied to resources"
  type        = string
  default     = "Schedule"
}

variable "scheduled_tag_value" {
  description = "The value of the tag that will be applied to resources"
  type        = string
}

variable "autoscaling_groups" {
  description = "Configuration for the autoscaling groups to tag"
  type = object({
    enable = optional(bool, false)
    # Indicates whether the default tags should be applied to the resources
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
    scheduled_tag_name = optional(string, null)
    # Override the default scheduled_tag_name if provided
    scheduled_tag_value = optional(string, null)
    # Override the default scheduled_tag_value if provided
  })
  default = {
    enable = false
  }
}

variable "ec2_instances" {
  description = "Configuration for the EC2 instances to tag"
  type = object({
    enable = optional(bool, false)
    # Indicates whether the default tags should be applied to the resources
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {
    enable = false
  }
}

variable "rds_instances" {
  description = "Configuration for the RDS instances to tag"
  type = object({
    enable = optional(bool, false)
    # Indicates whether the default tags should be applied to the resources
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {
    enable = false
  }
}

variable "rds_clusters" {
  description = "Configuration for the RDS clusters to tag"
  type = object({
    enable = optional(bool, false)
    # Indicates whether the default tags should be applied to the resources
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {
    enable = false
  }
}

variable "neptune_clusters" {
  description = "Configuration for the Neptune clusters to tag"
  type = object({
    enable = optional(bool, false)
    # Indicates whether the default tags should be applied to the resources
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {
    enable = false
  }
}

variable "tags" {
  description = "A map of tags to apply to the resources"
  type        = map(string)
}
