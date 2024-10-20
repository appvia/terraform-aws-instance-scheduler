#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "standalone_spoke" {
  source = "../.."

  enable_organizations = true
  enable_standalone    = true
  enable_stackset      = false
  region               = "eu-west-2"
  scheduler_account_id = "123456789012"

  tags = {
    "Environment" = "Development"
    "Owner"       = "Solutions"
    "Product"     = "LandingZone"
    "Provisioner" = "Terraform"
    "GitRepo"     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }
}
