
variable "dyanmodb_table_name" {
  description = "The name of the DynamoDB table to use for the scheduler"
  type        = string
}

variable "periods" {
  description = "A period to create with the instance scheduler"
  type = map(object({
    description = string
    end_time    = optional(string, null)
    months      = optional(list(string), null)
    start_time  = optional(string, null)
    weekdays    = optional(list(string), null)
  }))
  default = {}
}

variable "schedules" {
  description = "The schedule to create within the scheduler"
  type = map(object({
    description     = string
    override_status = optional(string, null)
    periods         = list(string)
    timezone        = optional(string, "UTC")
  }))
  default = {}
}
