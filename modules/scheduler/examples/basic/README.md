## Scheduler Example

This example demonstrates the central-account deployment path for Instance Scheduler and a paired schedule configuration workflow. It is intended for platform teams bootstrapping a hub account in an AWS landing zone.

## Capabilities Demonstrated

- Hub scheduler deployment with explicit scheduling controls.
- Follow-on schedule/period provisioning using the exported DynamoDB table.
- Baseline composition pattern between `scheduler` and `config` modules.

## Usage Gallery

### Golden Path (Simple)

```hcl
locals {
  tags = {
    Environment = "development"
    Owner       = "platform"
  }
}

module "scheduler" {
  source = "../.."

  scheduler_tag_name          = "Schedule"
  scheduler_regions           = ["eu-west-2"]
  scheduler_organizations_ids = ["o-abc123xyz0"]
  scheduler_frequency         = 15
  tags                        = local.tags
}
```

### Power User (Advanced)

```hcl
locals {
  tags = {
    Environment = "production"
    Owner       = "platform"
    Compliance  = "pci"
  }
}

module "scheduler" {
  source = "../.."

  cloudformation_bucket_name     = "org-prod-instance-scheduler-templates"
  enable_cloudformation_macro    = true
  enable_cloudwatch_dashboard    = true
  enable_ssm_maintenance_windows = true
  enable_rds_snapshot            = true
  enable_debug                   = true
  scheduler_tag_name             = "Schedule"
  scheduler_regions              = ["eu-west-2", "eu-central-1"]
  scheduler_organizations_ids    = ["o-abc123xyz0"]
  scheduler_timezone             = "UTC"
  scheduler_log_group_retention  = "30"
  tags                           = local.tags
}
```

### Migration (Edge Case)

```hcl
locals {
  tags = {
    Environment = "migration"
    Owner       = "platform"
  }
}

module "scheduler" {
  source = "../.."

  cloudformation_hub_stack_name = "legacy-scheduler-hub"
  scheduler_tag_name            = "InstanceSchedule"
  scheduler_asg_tag_key         = "legacy-scheduled"
  scheduler_asg_rule_prefix     = "legacy-"
  scheduler_regions             = ["eu-west-2"]
  scheduler_frequency           = 30
  enable_hub_account_scheduler  = false
  tags                          = local.tags
}
```

## Known Limitations

- CloudFormation stack creation and updates are asynchronous and can take several minutes.
- Example values assume a centralized org model; account and OU IDs must be replaced.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudformation_scheduler_arn"></a> [cloudformation\_scheduler\_arn](#output\_cloudformation\_scheduler\_arn) | The ARN for the scheduler cloudformation scheduler template |
| <a name="output_cloudformation_scheduler_url"></a> [cloudformation\_scheduler\_url](#output\_cloudformation\_scheduler\_url) | The URL for the scheduler cloudformation scheduler template |
| <a name="output_cloudformation_spoke_arn"></a> [cloudformation\_spoke\_arn](#output\_cloudformation\_spoke\_arn) | The ARN for the spoke cloudformation scheduler template |
| <a name="output_cloudformation_spoke_url"></a> [cloudformation\_spoke\_url](#output\_cloudformation\_spoke\_url) | The URL for the spoke cloudformation scheduler template |
<!-- END_TF_DOCS -->