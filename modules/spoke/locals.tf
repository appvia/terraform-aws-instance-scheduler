
locals {
  ## Is the current region 
  region = var.region

  ## Parameters for the cloudformation stack in the spoke accounts 
  cloudformation_spoke_stack_parameters = {
    InstanceSchedulerAccount : var.scheduler_account_id
    UsingAWSOrganizations : var.enable_organizations ? "yes" : "no"
    KmsKeyArns : join(",", var.kms_key_arns)
  }
}
