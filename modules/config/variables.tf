
variable "dyanmodb_table_name" {
  description = "The name of the DynamoDB table to use for the scheduler"
  type        = string
}

variable "periods" {
  description = "A period to create with the instance scheduler"
  type = map(object({
    description = string
    # A human-readable description of the period 
    end_time = optional(string, null)
    # The end time of the period 
    months = optional(list(string), null)
    # The months to apply to the period 
    start_time = optional(string, null)
    # The start time of the period
    weekdays = optional(list(string), null)
    # The weekdays to apply to the period
  }))
  default = {}
}

variable "schedules" {
  description = "The schedule to create within the scheduler"
  type = map(object({
    description = string
    # A human-readable description of the schedule 
    enforced = optional(bool, null)
    # Whether the schedule is enforced 
    override_status = optional(string, null)
    # The status to set when the schedule is enforced 
    periods = list(string)
    # The periods to apply to the schedule 
    stop_new_instances = optional(bool, null)
    # Whether to stop new instances 
    timezone = optional(string, "UTC")
    # The timezone to use for the schedule
  }))
  default = {}
}
