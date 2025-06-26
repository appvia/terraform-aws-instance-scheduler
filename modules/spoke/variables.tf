
variable "cloudformation_spoke_stack_name" {
  description = "The name of the cloudformation stack in the spoke accounts"
  type        = string
  default     = "lza-instance-scheduler-spoke"
}

variable "enable_stackset" {
  description = "Whether the stackset should be enabled"
  type        = bool
  default     = false
}

variable "organizational_units" {
  description = "The organizational units to deploy the stack to (when using a stackset)"
  type        = map(string)
  default     = {}
}

variable "enable_cloudformation_macro" {
  description = "Whether the cloudformation macro should be enabled"
  type        = bool
  default     = true
}

variable "cloudformation_macro_name" {
  description = "The name of the cloudformation macro"
  type        = string
  default     = "AddDefaultTags"
}

variable "enable_organizations" {
  description = "Whether the stack should be enabled for AWS Organizations"
  type        = bool
  default     = true
}

variable "enable_standalone" {
  description = "Whether the stack should be standalone"
  type        = bool
  default     = true
}

variable "scheduler_account_id" {
  description = "The account id of where the orchcastrator is running"
  type        = string

  # Should be a validate account id
  validation {
    condition     = can(regex("^[0-9]{12}$", var.scheduler_account_id))
    error_message = "The scheduler_account_id must be a valid AWS account id"
  }
}

variable "kms_key_arns" {
  description = "The KMS key ARNs used to encrypt the instance scheduler data"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "The region in which the resources should be created"
  type        = string
  default     = null
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}
