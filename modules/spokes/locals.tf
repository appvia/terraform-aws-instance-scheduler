
locals {
  ## Is the current region
  region = data.aws_region.current.region
  ## Parameters for the cloudformation stack in the spoke accounts
  cloudformation_spoke_stack_parameters = {
    InstanceSchedulerAccount = var.scheduler_account_id
    KmsKeyArns               = join(",", var.kms_key_arns)
    UsingAWSOrganizations    = var.enable_organizations ? "Yes" : "No"
  }
}
