#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "scheduler" {
  source = "../.."

  enable_cloudwatch_dashboard = false
  enable_debug                = true
  enable_organizations        = true
  enable_rds_snapshot         = false
  enable_scheduler            = true
  ## The organizational id
  organizational_id = "o-7enwqk0f2c"
  ## The regions that the scheduler will manage resources in
  scheduler_regions = ["eu-west-2"]
  ## The tag placed on the resources that the scheduler will manage
  ## the lifecycle for based on the schedules and periods defined
  scheduler_tag_name = "Schedule"
  ## The tags used on ASG resources to identify the resources that should be started
  scheduler_asg_tag_key = "Schedule"
  ## Is the interval in minutes that the scheduler will check for resources
  ## that need to be started or stopped
  scheduler_frequency = 5
  ## The organizations id that are permitted to use the scheduler - you can
  ## this detail in the AWS Organizations console
  scheduler_organizations_ids = ["o-7enwqk0f2c"]

  tags = {
    "Environment" = "Development"
    "Owner"       = "Solutions"
    "Product"     = "LandingZone"
    "Provisioner" = "Terraform"
    "GitRepo"     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }
}

module "config" {
  source = "../../../config"

  dyanmodb_table_name = module.scheduler.scheduler_dynamodb_table

  periods = {
    "uk_working_hours" = {
      description = "Resources will run during the UK working hours, anything outside of this will be stopped"
      start_time  = "06:00"
      end_time    = "19:00"
      weekdays    = ["mon-fri"]
    }
  }

  schedules = {
    "uk_working_hours" = {
      description = "Start resources at 06:00 and stop them at 19:30"
      periods     = ["uk_working_hours"]
      timezone    = "Europe/London"
    }
  }

  depends_on = [
    module.scheduler
  ]
}
