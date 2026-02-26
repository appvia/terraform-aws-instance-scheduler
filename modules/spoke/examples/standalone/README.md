## Spoke Standalone Example

This example shows how to onboard a single AWS account to a centralized scheduler hub without StackSets. It is useful for phased adoption, pilots, or exception accounts outside normal OU rollout patterns.

## Capabilities Demonstrated

- Standalone spoke deployment for one account.
- Optional pairing with tag enforcement to improve schedule-tag coverage.
- Baseline migration path before wider organization rollout.

## Usage Gallery

### Golden Path (Simple)

```hcl
locals {
  tags = {
    Environment = "development"
    Owner       = "platform"
  }
}

module "standalone_spoke" {
  source = "../.."

  scheduler_account_id = "111122223333"
  enable_standalone    = true
  enable_stackset      = false
  tags                 = local.tags
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

module "standalone_spoke" {
  source = "../.."

  scheduler_account_id                = "111122223333"
  cloudformation_bucket_name_prefix   = "prod-instance-scheduler-spoke"
  cloudformation_spoke_stack_name     = "prod-instance-scheduler-spoke"
  enable_cloudformation_macro         = true
  cloudformation_macro_name           = "AddDefaultTags"
  cloudformation_transform_stack_name = "prod-spoke-add-default-tags"
  enable_standalone                   = true
  enable_stackset                     = false
  kms_key_arns                        = ["arn:aws:kms:eu-west-2:111122223333:key/abcd-1234"]
  tags                                = local.tags
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

module "standalone_spoke" {
  source = "../.."

  scheduler_account_id              = "111122223333"
  cloudformation_spoke_stack_name   = "legacy-instance-scheduler-spoke"
  cloudformation_bucket_name_prefix = "legacy-instance-scheduler-spoke"
  enable_cloudformation_macro       = false
  enable_standalone                 = true
  enable_stackset                   = false
  tags                              = local.tags
}
```

## Known Limitations

- This example targets a single account; use StackSet-based modules for large-scale OU deployments.
- CloudFormation execution timing can vary and may delay scheduler registration in downstream workflows.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->