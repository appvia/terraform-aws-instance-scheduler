
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

variable "enable_autoscaling" {
  description = "Whether autoscaling groups should be tagged"
  type        = bool
  default     = false
}

variable "enable_ec2" {
  description = "Whether EC2 instances should be tagged"
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "Whether RDS instances should be tagged"
  type        = bool
  default     = false
}

variable "enable_documentdb" {
  description = "Whether DocumentDB clusters should be tagged"
  type        = bool
  default     = false
}

variable "enable_aurora" {
  description = "Whether Aurora clusters should be tagged"
  type        = bool
  default     = false
}

variable "enable_neptune" {
  description = "Whether Neptune clusters should be tagged"
  type        = bool
  default     = false
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

variable "autoscaling" {
  description = "Configuration for the autoscaling groups to tag"
  type = object({
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

variable "ec2" {
  description = "Configuration for the EC2 instances to tag"
  type = object({
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {
    enable = false
  }
}

variable "documentdb" {
  description = "Configuration for the DocumentDB clusters to tag"
  type = object({
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {
    enable = false
  }
}

variable "aurora" {
  description = "Configuration for the Aurora clusters to tag"
  type = object({
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {
  }
}

variable "rds" {
  description = "Configuration for the RDS instances to tag"
  type = object({
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {}
}

variable "neptune" {
  description = "Configuration for the Neptune clusters to tag"
  type = object({
    excluded_tags = optional(list(string), [])
    # List of tags on resources that should be excluded from the tagging process
    schedule = optional(string, null)
    # Override the default schedule if provided
  })
  default = {}
}

variable "tags" {
  description = "A map of tags to apply to the resources"
  type        = map(string)
}
