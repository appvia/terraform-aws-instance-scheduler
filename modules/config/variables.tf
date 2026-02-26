
variable "dyanmodb_table_name" {
  description = "The name of the DynamoDB table to use for the scheduler"
  type        = string
}

variable "periods" {
  description = "A period to create with the instance scheduler"
  type = map(object({
    # A human-readable description of the period
    description = string
    # The end time of the period
    end_time = optional(string, null)
    # The months to apply to the period
    months = optional(list(string), null)
    # The start time of the period
    start_time = optional(string, null)
    # The weekdays to apply to the period
    weekdays = optional(list(string), null)
  }))
  default = {}
}

variable "schedules" {
  description = "The schedule to create within the scheduler"
  type = map(object({
    # A human-readable description of the schedule
    description = string
    # Whether the schedule is enforced
    enforced = optional(bool, null)
    # The status to set when the schedule is enforced
    override_status = optional(string, null)
    # The periods to apply to the schedule
    periods = list(string)
    # Whether to stop new instances
    stop_new_instances = optional(bool, null)
    # The timezone to use for the schedule
    timezone = optional(string, "UTC")
  }))
  default = {}
}
