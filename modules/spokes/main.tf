
## Provision the cloudformation macro if required
module "cloudformation_macro" {
  count  = var.enable_cloudformation_macro ? 1 : 0
  source = "../macro"

  name_prefix                         = "spoke-default-tags"
  cloudformation_transform_name       = var.cloudformation_macro_name
  cloudformation_transform_stack_name = var.cloudformation_transform_stack_name
  tags                                = var.tags
}

## Provision the cloudformation stack within the spoke accounts
resource "aws_cloudformation_stack_set" "spokes" {
  capabilities     = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
  description      = "Used to deploy the instance scheduler stack to spoke accounts"
  name             = var.cloudformation_spoke_stack_name
  parameters       = local.cloudformation_spoke_stack_parameters
  permission_model = "SERVICE_MANAGED"
  tags             = var.tags
  template_url     = var.cloudformation_bucket_url

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = true
  }

  lifecycle {
    ignore_changes = [administration_role_arn]
  }

  depends_on = [
    module.cloudformation_macro
  ]
}

## Provision a stackset to the organizational units if enabled
resource "aws_cloudformation_stack_set_instance" "spokes" {
  for_each = var.organizational_units

  stack_set_name            = aws_cloudformation_stack_set.spokes.name
  stack_set_instance_region = local.region

  operation_preferences {
    failure_tolerance_count = 0
    max_concurrent_count    = 10
    region_concurrency_type = "PARALLEL"
  }

  deployment_targets {
    organizational_unit_ids = [each.value]
  }
}

