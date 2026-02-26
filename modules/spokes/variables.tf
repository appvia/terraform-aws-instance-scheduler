
variable "cloudformation_bucket_name" {
  description = "The name of the S3 bucket used to store the cloudformation templates"
  type        = string
  default     = "lz-instance-scheduler-spoke-templates"
}

variable "cloudformation_macro_name" {
  description = "The name of the cloudformation macro"
  type        = string
  default     = "AddDefaultTags"
}

variable "cloudformation_spoke_stack_name" {
  description = "The name of the cloudformation stack in the spoke accounts"
  type        = string
  default     = "lz-instance-scheduler-spokes"
}

variable "cloudformation_transform_stack_name" {
  description = "The name of the cloudformation transform stack"
  type        = string
  default     = "lz-instance-scheduler-spoke-add-default-tags"
}

variable "enable_cloudformation_macro" {
  description = "Whether the cloudformation macro should be enabled"
  type        = bool
  default     = true
}

variable "enable_organizations" {
  description = "Whether the organizations should be enabled"
  type        = bool
  default     = true
}

variable "kms_key_arns" {
  description = "The KMS key ARNs used to encrypt the instance scheduler data"
  type        = list(string)
  default     = []
}

variable "organizational_units" {
  description = "The organizational units to deploy the stack to (when using a stackset)"
  type        = map(string)
  default     = {}
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

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}
