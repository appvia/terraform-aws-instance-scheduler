variable "architecture" {
  description = "Lambda function architecture"
  type        = string
  default     = "arm64"
}

variable "cloudformation_transform_name" {
  description = "Name of the cloudformation transform"
  type        = string
  default     = "AddDefaultTags"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
}

variable "log_kms_key_id" {
  description = "KMS key ID to use for CloudWatch log encryption"
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "name_prefix" {
  description = "Prefix to be used for naming resources"
  type        = string
  default     = "default-tags"
}

variable "runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.12"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}
