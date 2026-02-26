![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler Spoke

This module connects managed AWS accounts to a central scheduler hub. It solves the onboarding problem in multi-account environments by deploying the remote scheduler CloudFormation stack in spoke accounts, either as standalone deployment or StackSet-driven rollout.

Architecture overview:

- Terraform creates and secures a template bucket for the remote scheduler template.
- The remote CloudFormation template is uploaded once per region.
- Depending on flags, the module deploys either a standalone stack (single account) or StackSet instances (multi-account OUs).
- Optional macro integration enables default-tag injection on spoke-side CloudFormation resources.

## Capabilities

- **Security by default**: Private, encrypted template bucket with transport and encryption policy protections.
- **Flexible rollout modes**: Supports standalone account deployment and organization-scale StackSet distribution.
- **Operational consistency**: Keeps spoke onboarding declarative and repeatable from one Terraform workflow.
- **Landing zone alignment**: Designed for hub-and-spoke AWS organization models.
- **Compliance support**: Standardized onboarding and tagging controls support governance baselines used in SOC 2 and ISO 27001 programs.

## Usage Gallery

### Golden Path (Simple)

```hcl
locals {
  tags = {
    Environment = "development"
    Owner       = "platform"
  }
}

module "spoke" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spoke?ref=main"

  scheduler_account_id = "111122223333"
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

module "spoke" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spoke?ref=main"

  scheduler_account_id                = "111122223333"
  cloudformation_bucket_name          = "org-prod-instance-scheduler-spoke"
  cloudformation_spoke_stack_name     = "org-prod-instance-scheduler-spoke"
  enable_cloudformation_macro         = true
  cloudformation_macro_name           = "AddDefaultTags"
  cloudformation_transform_stack_name = "org-prod-spoke-add-default-tags"
  organizational_units = {
    engineering = "ou-abcd-11111111"
    data        = "ou-abcd-22222222"
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

module "spoke" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spoke?ref=main"

  scheduler_account_id              = "111122223333"
  cloudformation_spoke_stack_name   = "legacy-instance-scheduler-spoke"
  cloudformation_bucket_name_prefix = "legacy-instance-scheduler-spoke"
  enable_cloudformation_macro       = false
  tags                              = local.tags
}
```

## Known Limitations

- StackSet rollouts require AWS Organizations trusted access and appropriate delegated administrator permissions.
- CloudFormation operations are asynchronous; OU-wide rollouts can take significant time in large organizations.
- Bucket names remain globally unique and may need environment/account scoping to avoid collisions.
- This module is in transition with `modules/spokes`; verify the preferred module path for your branch.

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
| <a name="input_scheduler_account_id"></a> [scheduler\_account\_id](#input\_scheduler\_account\_id) | The account id of where the orchcastrator is running | `string` | n/a | yes |
| <a name="input_artifacts_dir"></a> [artifacts\_dir](#input\_artifacts\_dir) | The output path to store lambda function code artifacts | `string` | `"builds"` | no |
| <a name="input_cloudformation_bucket_name"></a> [cloudformation\_bucket\_name](#input\_cloudformation\_bucket\_name) | The name of the S3 bucket used to store the cloudformation templates (region added) | `string` | `"lz-instance-scheduler-spoke-templates"` | no |
| <a name="input_cloudformation_macro_name"></a> [cloudformation\_macro\_name](#input\_cloudformation\_macro\_name) | The name of the cloudformation macro | `string` | `"AddDefaultTags"` | no |
| <a name="input_cloudformation_spoke_stack_name"></a> [cloudformation\_spoke\_stack\_name](#input\_cloudformation\_spoke\_stack\_name) | The name of the cloudformation stack in the spoke accounts | `string` | `"lz-instance-scheduler-spoke"` | no |
| <a name="input_cloudformation_transform_stack_name"></a> [cloudformation\_transform\_stack\_name](#input\_cloudformation\_transform\_stack\_name) | The name of the cloudformation transform stack | `string` | `"lz-instance-scheduler-spoke-add-default-tags"` | no |
| <a name="input_enable_cloudformation_macro"></a> [enable\_cloudformation\_macro](#input\_enable\_cloudformation\_macro) | Whether the cloudformation macro should be enabled | `bool` | `true` | no |
| <a name="input_enable_organizations"></a> [enable\_organizations](#input\_enable\_organizations) | Whether the organizations should be enabled | `bool` | `true` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | The KMS key ARNs used to encrypt the instance scheduler data | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 bucket used to store the cloudformation templates |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the S3 bucket used to store the cloudformation templates |
| <a name="output_cloudformation_arn"></a> [cloudformation\_arn](#output\_cloudformation\_arn) | The ARN of the cloudformation stack deployed to the spoke account |
<!-- END_TF_DOCS -->
