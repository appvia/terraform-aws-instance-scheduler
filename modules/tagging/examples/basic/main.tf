#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "tagging_enforcement" {
  source = "../../"

  ## The tag name
  scheduler_tag_name = "Schedule"
  ## The default tag value 
  scheduler_tag_value = "uk_office_hours"
  ## Cron for every 15 minutes
  schedule = "rate(15 minutes)"

  ## Enable tagging for the following resources 
  enable_autoscaling = true
  enable_ec2         = true
  enable_rds         = true

  autoscaling = {
    schedule = "cron(0 8 * * ? *)"
  }

  tags = {
    Environment = "Production"
    Owner       = "Solutions"
    Product     = "LandingZone"
    GitRepo     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }
}
