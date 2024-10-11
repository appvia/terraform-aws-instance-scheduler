
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
