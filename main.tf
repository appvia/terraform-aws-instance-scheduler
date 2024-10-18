
## Provision the cloudformation stack within the centralized account 
resource "aws_cloudformation_stack" "hub" {
  name         = var.cloudformation_hub_stack_name
  capabilities = var.cloudformation_hub_stack_capabilities
  parameters   = local.cloudformation_hub_stack_parameters

  template_body = templatefile("${path.module}/assets/cloudformation/instance-scheduler-on-aws.template", {
    account_id = local.account_id,
    tags       = var.tags
  })
}

## Provision the cloudformation stack within the spoke accounts 
module "spokes" {
  source  = "appvia/stackset/aws"
  version = "0.1.2"

  name                 = var.cloudformation_spoke_stack_name
  description          = "Used to deploy the instance scheduler stack to spoke accounts"
  parameters           = local.cloudformation_spoke_stack_parameters
  region               = local.region
  tags                 = var.tags
  organizational_units = var.instance_scheduler_organizational_units

  template = templatefile("${path.module}/assets/cloudformation/instance-scheduler-on-aws-remote.template", {
    account_id = local.account_id,
    tags       = var.tags
  })

  providers = {
    aws = aws.stacks
  }
}
