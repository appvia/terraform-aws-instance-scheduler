#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "config" {
  source = "../.."

  dyanmodb_table_name = "my-scaling-scheduler"

  periods = {
    "morning" = {
      description = "Morning period"
      name        = "morning"
      start_time  = "08:00"
      end_time    = "12:00"
      weekdays    = ["mon", "tue", "wed", "thu", "fri"]
    }
    "afternoon" = {
      description = "Afternoon period"
      name        = "afternoon"
      start_time  = "12:00"
      end_time    = "16:00"
      weekdays    = ["mon", "tue", "wed", "thu", "fri"]
    }
    "evening" = {
      description = "Evening period"
      name        = "evening"
      start_time  = "16:00"
      end_time    = "20:00"
      weekdays    = ["mon", "tue", "wed", "thu", "fri"]
    }
  }

  schedules = {
    "morning" = {
      description = "Morning schedule"
      name        = "morning"
      periods     = ["morning"]
      timezone    = "Europe/London"
    }
    "afternoon" = {
      description = "Afternoon schedule"
      name        = "afternoon"
      periods     = ["afternoon"]
      timezone    = "Europe/London"
    }
    "evening" = {
      description = "Evening schedule"
      name        = "evening"
      periods     = ["evening"]
      timezone    = "Europe/London"
    }
  }
}
