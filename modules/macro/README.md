![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler Macro

This module provides a CloudFormation transform macro that injects default tags into resources created by CloudFormation templates. It solves the governance gap where stack-level tagging is required, but upstream templates do not consistently apply resource tags.

Architecturally, Terraform packages a Lambda function, provisions invocation permissions, and registers the function as a CloudFormation macro stack. The scheduler and spoke modules can then reference this transform so tags are applied automatically during stack operations.

## Capabilities

- **Security by default**: Dedicated execution role and log group controls, with optional KMS encryption for logs.
- **Operational consistency**: Applies a single default tagging contract across CloudFormation resources.
- **Flexible integration**: Reusable as a standalone macro module or embedded from scheduler/spoke modules.
- **Landing zone fit**: Useful for centrally governed AWS organizations where platform teams enforce standard tagging.
- **Compliance support**: Improves evidence for tag-based governance controls often used in SOC 2 and ISO 27001.

## Usage Gallery

### Golden Path (Simple)

```hcl
locals {
  tags = {
    Environment = "development"
    Owner       = "platform"
    Product     = "landing-zone"
  }
}

module "macro" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/macro?ref=main"

  cloudformation_transform_name       = "SchedulerAddDefaultTags"
  cloudformation_transform_stack_name = "lza-instance-scheduler-add-default-tags"
  tags                                = local.tags
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

module "macro" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/macro?ref=main"

  name_prefix                         = "scheduler-default-tags"
  cloudformation_transform_name       = "SchedulerAddDefaultTags"
  cloudformation_transform_stack_name = "scheduler-macro-prod"
  architecture                        = "arm64"
  runtime                             = "python3.12"
  memory_size                         = 256
  timeout                             = 120
  log_retention_days                  = 30
  log_kms_key_id                      = "arn:aws:kms:eu-west-2:111122223333:key/abcd-1234"
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

module "macro" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/macro?ref=main"

  name_prefix                         = "legacy-default-tags"
  cloudformation_transform_name       = "LegacyAddDefaultTags"
  cloudformation_transform_stack_name = "legacy-transform-stack"
  log_retention_days                  = 14
  tags                                = local.tags
}
```

## Known Limitations

- The macro only affects CloudFormation templates that explicitly use the registered transform.
- Tag injection depends on resource-level tag support in each AWS service.
- Macro updates are CloudFormation stack updates; propagation is not instantaneous during active deployment windows.
- Lambda package generation happens at plan/apply time from local module assets, so CI workers must have the required provider/runtime tooling.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudformation_transform_name"></a> [cloudformation\_transform\_name](#input\_cloudformation\_transform\_name) | Name of the cloudformation transform | `string` | n/a | yes |
| <a name="input_cloudformation_transform_stack_name"></a> [cloudformation\_transform\_stack\_name](#input\_cloudformation\_transform\_stack\_name) | Name of the cloudformation transform stack | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Lambda function architecture | `string` | `"arm64"` | no |
| <a name="input_log_kms_key_id"></a> [log\_kms\_key\_id](#input\_log\_kms\_key\_id) | KMS key ID to use for CloudWatch log encryption | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention period in days | `number` | `14` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory size in MB | `number` | `128` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to be used for naming resources | `string` | `"default-tags"` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda runtime environment | `string` | `"python3.12"` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout in seconds | `number` | `60` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | ARN of the Lambda function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Name of the Lambda function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN of the Lambda execution role |
| <a name="output_macro_name"></a> [macro\_name](#output\_macro\_name) | Name of the CloudFormation macro |
<!-- END_TF_DOCS -->