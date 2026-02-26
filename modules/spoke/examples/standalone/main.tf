#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "standalone_spoke" {
  source = "../.."

  cloudformation_bucket_name = "lz-instance-scheduler-templates"
  scheduler_account_id       = "970526142943"

  tags = {
    "Environment" = "Development"
    "Owner"       = "Solutions"
    "Product"     = "LandingZone"
    "Provisioner" = "Terraform"
    "GitRepo"     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }
}

## Ensure the resources are tagging correctly
module "tagging" {
  source = "../../../tagging"

  enable_autoscaling  = true
  scheduler_tag_name  = "Schedule"
  scheduler_tag_value = "uk_working_hours"
  schedule            = "rate(5 minutes)"

  tags = {
    Environment = "Production"
    Owner       = "Solutions"
    Product     = "LandingZone"
    GitRepo     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }
}
