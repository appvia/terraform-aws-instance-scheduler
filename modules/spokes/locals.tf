
locals {
  ## The account id of the spoke account
  account_id = data.aws_caller_identity.current.account_id
  ## Is the current region
  region = data.aws_region.current.region
  ## The expected arn of the s3 bucket
  bucket_arn = format("arn:aws:s3:::%s", var.cloudformation_bucket_name)
  ## Parameters for the cloudformation stack in the spoke accounts
  cloudformation_spoke_stack_parameters = {
    InstanceSchedulerAccount = var.scheduler_account_id
    KmsKeyArns               = join(",", var.kms_key_arns)
    UsingAWSOrganizations    = var.enable_organizations ? "Yes" : "No"
  }
}
