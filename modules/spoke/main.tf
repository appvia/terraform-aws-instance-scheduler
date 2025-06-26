
## Provision the cloudformation stack within the spoke accounts
module "spokes" {
  count   = var.enable_stackset ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.1.10"

  name                 = var.cloudformation_spoke_stack_name
  description          = "Used to deploy the instance scheduler stack to spoke accounts"
  parameters           = local.cloudformation_spoke_stack_parameters
  region               = local.region
  tags                 = var.tags
  organizational_units = values(var.organizational_units)
  template             = file("${path.module}/assets/cloudformation/instance-scheduler-on-aws-remote.template")
}

## Provision the cloudformation macro if required 
module "cloudformation_macro" {
  count  = var.enable_cloudformation_macro ? 1 : 0
  source = "../macro"

  name_prefix                   = "spoke-add-default-tags"
  cloudformation_transform_name = local.cloudformation_macro_name
  tags                          = var.tags
}


## Provision a standalone cloudformation stack within the spoke account
resource "aws_cloudformation_stack" "spoke" {
  count = var.enable_standalone ? 1 : 0

  name         = var.cloudformation_spoke_stack_name
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
  parameters   = local.cloudformation_spoke_stack_parameters
  tags         = var.tags
  template_body = templatefile("${path.module}/assets/cloudformation/instance-scheduler-on-aws-remote.template", {
    enable_macro = var.enable_cloudformation_macro
    macro_name   = var.cloudformation_macro_name
  })

  depends_on = [module.cloudformation_macro]
}

