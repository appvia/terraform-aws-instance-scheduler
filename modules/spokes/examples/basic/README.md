## Spokes StackSet Example

This example demonstrates organization-wide onboarding of spoke accounts using StackSets. It solves the scale challenge of applying scheduler trust and access patterns consistently across many accounts.

## Capabilities Demonstrated

- OU-targeted StackSet deployment model.
- Central template distribution through a secure S3 bucket.
- Baseline multi-account rollout pattern for AWS landing zones.

## Usage Gallery

### Golden Path (Simple)

```hcl
locals {
  tags = {
    Environment = "development"
    Owner       = "platform"
  }
}

module "spokes" {
  source = "../.."

  scheduler_account_id = "111122223333"
  organizational_units = {
    engineering = "ou-abcd-11111111"
  }
  tags = local.tags
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

module "spokes" {
  source = "../.."

  scheduler_account_id                = "111122223333"
  cloudformation_bucket_name          = "org-prod-instance-scheduler-spokes-templates"
  cloudformation_spoke_stack_name     = "org-prod-instance-scheduler-spokes"
  enable_cloudformation_macro         = true
  cloudformation_macro_name           = "AddDefaultTags"
  cloudformation_transform_stack_name = "org-prod-spokes-add-default-tags"
  organizational_units = {
    engineering = "ou-abcd-11111111"
    data        = "ou-abcd-22222222"
    sandbox     = "ou-abcd-33333333"
  }
  kms_key_arns = ["arn:aws:kms:eu-west-2:111122223333:key/abcd-1234"]
  tags         = local.tags
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

module "spokes" {
  source = "../.."

  scheduler_account_id            = "111122223333"
  cloudformation_spoke_stack_name = "legacy-instance-scheduler-spokes"
  cloudformation_bucket_name      = "legacy-instance-scheduler-spokes-templates"
  enable_cloudformation_macro     = false
  organizational_units = {
    legacy_apps = "ou-abcd-99999999"
  }
  tags = local.tags
}
```

## Known Limitations

- Requires AWS Organizations trusted access and StackSet service-managed permissions.
- Rollout speed depends on OU size and per-account CloudFormation concurrency constraints.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->