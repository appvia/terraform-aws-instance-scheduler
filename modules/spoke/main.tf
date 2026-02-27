
## Provision the cloudformation macro if required
module "cloudformation_macro" {
  count  = var.enable_cloudformation_macro ? 1 : 0
  source = "../macro"

  artifacts_dir                       = var.artifacts_dir
  name_prefix                         = "spoke-default-tags"
  cloudformation_transform_name       = var.cloudformation_macro_name
  cloudformation_transform_stack_name = var.cloudformation_transform_stack_name
  tags                                = var.tags
}

## Provision a standalone cloudformation stack within the spoke account
resource "aws_cloudformation_stack" "spoke" {
  name         = var.cloudformation_spoke_stack_name
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
  parameters   = local.cloudformation_spoke_stack_parameters
  tags         = var.tags
  template_url = var.cloudformation_bucket_url

  depends_on = [
    module.cloudformation_macro,
  ]
}

