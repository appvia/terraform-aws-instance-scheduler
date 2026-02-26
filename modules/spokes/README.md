![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler Spoke

This module is the organization-scale spoke onboarding path for Instance Scheduler. It solves the challenge of deploying scheduler trust and configuration consistently across many AWS accounts by using CloudFormation StackSets targeted at organizational units.

Architecture overview:
- Terraform references the hardened scheduler S3 template bucket in the management account.
- The remote scheduler template is consumed from the published scheduler path and referenced by a StackSet.
- A StackSet instance is created per configured OU, allowing AWS Organizations to manage account enrollment.
- Optional macro integration enables consistent default tagging behavior in deployed spoke stacks.

## Capabilities

- **Security by default**: Consumes templates from the hardened scheduler bucket with strict transport and encryption guardrails.
- **Scalable rollout**: OU-based StackSet targeting for large multi-account estates.
- **Operational excellence**: Auto-deployment support helps onboard new accounts joining targeted OUs.
- **Landing zone alignment**: Designed explicitly for AWS Organizations hub-and-spoke models.
- **Compliance support**: Standardized account onboarding and tag controls support SOC 2 and ISO 27001 governance objectives.

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
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spokes?ref=main"

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
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spokes?ref=main"

  scheduler_account_id                = "111122223333"
  cloudformation_bucket_name          = "org-prod-instance-scheduler-templates"
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
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spokes?ref=main"

  scheduler_account_id            = "111122223333"
  cloudformation_spoke_stack_name = "legacy-instance-scheduler-spokes"
  cloudformation_bucket_name      = "legacy-instance-scheduler-templates"
  enable_cloudformation_macro     = false
  organizational_units = {
    legacy_apps = "ou-abcd-99999999"
  }
  tags = local.tags
}
```

## Known Limitations

- Requires AWS Organizations trusted access for StackSets and appropriate management/delegated admin permissions.
- StackSet deployment across large OUs can be slow and subject to per-account CloudFormation limits.
- Bucket naming is globally unique, so shared naming conventions must avoid conflicts.
- Existing account-level manual scheduler stacks can conflict with StackSet-managed resources during migration.

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scheduler_account_id"></a> [scheduler\_account\_id](#input\_scheduler\_account\_id) | The account id of where the instance scheduler is running | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the resources | `map(string)` | n/a | yes |
| <a name="input_cloudformation_bucket_name"></a> [cloudformation\_bucket\_name](#input\_cloudformation\_bucket\_name) | The name of the S3 bucket used to store the cloudformation templates | `string` | `"lz-instance-scheduler-templates"` | no |
| <a name="input_cloudformation_macro_name"></a> [cloudformation\_macro\_name](#input\_cloudformation\_macro\_name) | The name of the cloudformation macro | `string` | `"AddDefaultTags"` | no |
| <a name="input_cloudformation_spoke_stack_name"></a> [cloudformation\_spoke\_stack\_name](#input\_cloudformation\_spoke\_stack\_name) | The name of the cloudformation stack in the spoke accounts | `string` | `"lz-instance-scheduler-spokes"` | no |
| <a name="input_cloudformation_transform_stack_name"></a> [cloudformation\_transform\_stack\_name](#input\_cloudformation\_transform\_stack\_name) | The name of the cloudformation transform stack | `string` | `"lz-instance-scheduler-spoke-add-default-tags"` | no |
| <a name="input_enable_cloudformation_macro"></a> [enable\_cloudformation\_macro](#input\_enable\_cloudformation\_macro) | Whether the cloudformation macro should be enabled | `bool` | `true` | no |
| <a name="input_enable_organizations"></a> [enable\_organizations](#input\_enable\_organizations) | Whether the organizations should be enabled | `bool` | `true` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | The KMS key ARNs used to encrypt the instance scheduler data | `list(string)` | `[]` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The organizational units to deploy the stack to (when using a stackset) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 bucket used to store the cloudformation templates |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the S3 bucket used to store the cloudformation templates |
| <a name="output_stackset_arn"></a> [stackset\_arn](#output\_stackset\_arn) | The ARN of the stackset deployed to the spoke accounts |
<!-- END_TF_DOCS -->
