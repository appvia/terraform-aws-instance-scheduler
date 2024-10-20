#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "scheduler" {
  source = "../.."

  enable_asg_scheduler            = true
  enable_cloudwatch_dashboard     = false
  enable_cloudwatch_debug_logging = false
  enable_docdb_scheduler          = true
  enable_ec2_scheduler            = true
  enable_hub_account_scheduler    = false
  enable_neptune_scheduler        = false
  enable_organizations            = true
  enable_rds_cluster_scheduler    = true
  enable_rds_scheduler            = true
  enable_rds_snapshot             = false
  enable_scheduler                = true

  ## The organizational units that are permitted to use the scheduler 
  instance_scheduler_organizational_units = {
    "sandbox" = "o-7enwqk0f2c"
  }

  tags = {
    "Environment" = "Development"
    "Owner"       = "Solutions"
    "Product"     = "LandingZone"
    "Provisioner" = "Terraform"
    "GitRepo"     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }
}
