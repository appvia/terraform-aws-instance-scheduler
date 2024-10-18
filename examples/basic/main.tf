#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "hub" {
  source = "../.."

  enable_asg_scheduler            = true
  enable_cloudwatch_dashboard     = false
  enable_cloudwatch_debug_logging = true
  enable_docdb_scheduler          = true
  enable_ec2_scheduler            = true
  enable_hub_account_scheduler    = false
  enable_neptune_scheduler        = true
  enable_organizations            = true
  enable_rds_cluster_scheduler    = true
  enable_rds_scheduler            = true
  enable_rds_snapshot             = false
  enable_scheduler                = true
  region                          = "eu-west-2"

  tags = {
    "Environment" = "Development"
    "Owner"       = "Solutions"
    "Product"     = "LandingZone"
    "Provisioner" = "Terraform"
    "GitRepo"     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }

  providers = {
    aws        = aws.stacks
    aws.stacks = aws.stacks
  }
}
