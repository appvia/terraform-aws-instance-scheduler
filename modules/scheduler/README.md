![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler

This module is the hub control plane for Instance Scheduler on AWS. It solves the cost and governance problem of unmanaged EC2/RDS-family uptime by deploying the scheduler stack, publishing hub/spoke CloudFormation templates, and exposing core outputs needed by downstream modules.

Architecture flow:
- Terraform provisions a hardened S3 bucket for scheduler templates.
- The scheduler and remote templates are uploaded and then launched through CloudFormation in the hub account.
- Optional CloudFormation macro support injects default tags across stack resources.
- Downstream modules consume scheduler outputs (for example DynamoDB table name) to manage schedules and onboard spoke accounts.

## Capabilities

- **Security by default**: Encrypted S3 objects, strict bucket transport/encryption policies, and versioning enabled.
- **Platform flexibility**: Feature flags for EC2, RDS, RDS clusters, ASG, Neptune, DocumentDB, and maintenance windows.
- **Operational excellence**: Exposes CloudFormation template URLs and scheduler outputs for composable multi-module workflows.
- **Landing zone support**: Designed for centralized multi-account operation with AWS Organizations and organization-scoped principals.
- **Compliance support**: Policy-driven scheduling and auditable infrastructure changes align with SOC 2, ISO 27001, and PCI-DSS controls.

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

module "scheduler" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/scheduler?ref=main"

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
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/scheduler?ref=main"

  cloudformation_bucket_name      = "org-prod-instance-scheduler-templates"
  enable_cloudformation_macro     = true
  cloudformation_macro_name       = "SchedulerAddDefaultTags"
  enable_organizations            = true
  enable_organizational_bucket    = false
  enable_cloudwatch_dashboard     = true
  enable_ssm_maintenance_windows  = true
  enable_rds_snapshot             = true
  enable_debug                    = true
  scheduler_tag_name              = "Schedule"
  scheduler_regions               = ["eu-west-2", "eu-central-1"]
  scheduler_organizations_ids     = ["o-abc123xyz0"]
  scheduler_timezone              = "UTC"
  scheduler_log_group_retention   = "30"
  kms_key_arns                    = ["arn:aws:kms:eu-west-2:111122223333:key/abcd-1234"]
  tags                            = local.tags
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
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/scheduler?ref=main"

  cloudformation_hub_stack_name = "legacy-scheduler-hub"
  scheduler_tag_name            = "InstanceSchedule"
  scheduler_asg_tag_key         = "legacy-scheduled"
  scheduler_asg_rule_prefix     = "legacy-"
  scheduler_regions             = ["eu-west-2"]
  scheduler_frequency           = 30
  enable_scheduler              = true
  tags                          = local.tags
}
```

## Known Limitations

- Scheduler lifecycle is ultimately CloudFormation-managed, so updates can take several minutes and may fail on stack-level constraints.
- Template bucket names are globally unique; collisions must be managed in naming strategy.
- `scheduler_frequency` only accepts discrete values (`1, 2, 5, 10, 15, 30, 60`).
- If `enable_organizational_bucket` is used, your org setup and bucket policy expectations must be validated before rollout.

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
| <a name="input_scheduler_tag_name"></a> [scheduler\_tag\_name](#input\_scheduler\_tag\_name) | The tag name used to identify the resources that should be scheduled | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the resources | `map(string)` | n/a | yes |
| <a name="input_artifacts_dir"></a> [artifacts\_dir](#input\_artifacts\_dir) | The path to the directory where the Lambda function code artifacts are stored | `string` | `"builds"` | no |
| <a name="input_cloudformation_bucket_name"></a> [cloudformation\_bucket\_name](#input\_cloudformation\_bucket\_name) | The name of the S3 bucket used to store the cloudformation templates | `string` | `"lz-instance-scheduler-templates"` | no |
| <a name="input_cloudformation_hub_stack_capabilities"></a> [cloudformation\_hub\_stack\_capabilities](#input\_cloudformation\_hub\_stack\_capabilities) | The capabilities required for the cloudformation stack in the hub account | `list(string)` | <pre>[<br/>  "CAPABILITY_NAMED_IAM",<br/>  "CAPABILITY_AUTO_EXPAND",<br/>  "CAPABILITY_IAM"<br/>]</pre> | no |
| <a name="input_cloudformation_hub_stack_name"></a> [cloudformation\_hub\_stack\_name](#input\_cloudformation\_hub\_stack\_name) | The name of the cloudformation stack in the hub account | `string` | `"lz-instance-scheduler-hub"` | no |
| <a name="input_cloudformation_macro_name"></a> [cloudformation\_macro\_name](#input\_cloudformation\_macro\_name) | The name of the cloudformation macro | `string` | `"SchedulerAddDefaultTags"` | no |
| <a name="input_cloudformation_transform_stack_name"></a> [cloudformation\_transform\_stack\_name](#input\_cloudformation\_transform\_stack\_name) | The name of the cloudformation transform stack | `string` | `"lz-instance-scheduler-add-default-tags"` | no |
| <a name="input_enable_asg_scheduler"></a> [enable\_asg\_scheduler](#input\_enable\_asg\_scheduler) | Whether AutoScaling Groups should under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_cloudformation_macro"></a> [enable\_cloudformation\_macro](#input\_enable\_cloudformation\_macro) | Whether the cloudformation macro should be enabled | `bool` | `true` | no |
| <a name="input_enable_cloudwatch_dashboard"></a> [enable\_cloudwatch\_dashboard](#input\_enable\_cloudwatch\_dashboard) | Whether a CloudWatch dashboard used to monitor the scheduler should be created | `bool` | `false` | no |
| <a name="input_enable_debug"></a> [enable\_debug](#input\_enable\_debug) | Whether debug logging should be enabled for the instance scheduler | `bool` | `false` | no |
| <a name="input_enable_organizations"></a> [enable\_organizations](#input\_enable\_organizations) | Whether the instance scheduler should integrate with AWS Organizations | `bool` | `true` | no |
| <a name="input_enable_rds_snapshot"></a> [enable\_rds\_snapshot](#input\_enable\_rds\_snapshot) | Whether RDS instances should have snapshots created on stop | `bool` | `false` | no |
| <a name="input_enable_retain_logs"></a> [enable\_retain\_logs](#input\_enable\_retain\_logs) | Whether the instance scheduler should retain logs | `bool` | `false` | no |
| <a name="input_enable_scheduler"></a> [enable\_scheduler](#input\_enable\_scheduler) | Whether the instance scheduler should be enabled | `bool` | `true` | no |
| <a name="input_enable_ssm_maintenance_windows"></a> [enable\_ssm\_maintenance\_windows](#input\_enable\_ssm\_maintenance\_windows) | Whether EC2 instances should be managed by SSM Maintenance Windows | `bool` | `false` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | The KMS key ARNs used to encrypt the instance scheduler data | `list(string)` | `[]` | no |
| <a name="input_organizational_id"></a> [organizational\_id](#input\_organizational\_id) | The AWS Organization ID used in conjunction with the organizational bucket | `string` | `""` | no |
| <a name="input_scheduler_asg_rule_prefix"></a> [scheduler\_asg\_rule\_prefix](#input\_scheduler\_asg\_rule\_prefix) | The prefix used to identify the AutoScaling Group scheduled actions | `string` | `"is-"` | no |
| <a name="input_scheduler_asg_tag_key"></a> [scheduler\_asg\_tag\_key](#input\_scheduler\_asg\_tag\_key) | The tag key used to identify AutoScaling Groups that should be scheduled | `string` | `"scheduled"` | no |
| <a name="input_scheduler_frequency"></a> [scheduler\_frequency](#input\_scheduler\_frequency) | The frequency at which the instance scheduler should run in minutes | `number` | `60` | no |
| <a name="input_scheduler_log_group_retention"></a> [scheduler\_log\_group\_retention](#input\_scheduler\_log\_group\_retention) | The retention period for the instance scheduler log group | `string` | `"7"` | no |
| <a name="input_scheduler_memory_size"></a> [scheduler\_memory\_size](#input\_scheduler\_memory\_size) | The memory size for the instance scheduler | `number` | `128` | no |
| <a name="input_scheduler_orchestrator_memory_size"></a> [scheduler\_orchestrator\_memory\_size](#input\_scheduler\_orchestrator\_memory\_size) | The memory size for the instance scheduler orchestrator | `number` | `128` | no |
| <a name="input_scheduler_organizations_ids"></a> [scheduler\_organizations\_ids](#input\_scheduler\_organizations\_ids) | A list of organizations ids that are permitted to use the scheduler | `list(string)` | `[]` | no |
| <a name="input_scheduler_regions"></a> [scheduler\_regions](#input\_scheduler\_regions) | The regions in which the instance scheduler should operate | `list(string)` | `[]` | no |
| <a name="input_scheduler_start_tags"></a> [scheduler\_start\_tags](#input\_scheduler\_start\_tags) | The tags used to identify the resources that should be started | `string` | `"InstanceScheduler-LastAction=Started By {scheduler} {year}/{month}/{day} {hour}:{minute}{timezone},>"` | no |
| <a name="input_scheduler_stop_tags"></a> [scheduler\_stop\_tags](#input\_scheduler\_stop\_tags) | The tags used to identify the resources that should be stopped | `string` | `"InstanceScheduler-LastAction=Stopped By {scheduler} {year}/{month}/{day} {hour}:{minute}{timezone},>"` | no |
| <a name="input_scheduler_timezone"></a> [scheduler\_timezone](#input\_scheduler\_timezone) | The default timezone for the instance scheduler | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id of the scheduler |
| <a name="output_cloudformation_scheduler_arn"></a> [cloudformation\_scheduler\_arn](#output\_cloudformation\_scheduler\_arn) | The ARN for the scheduler cloudformation scheduler template |
| <a name="output_cloudformation_scheduler_url"></a> [cloudformation\_scheduler\_url](#output\_cloudformation\_scheduler\_url) | The URL for the scheduler cloudformation scheduler template |
| <a name="output_cloudformation_spoke_arn"></a> [cloudformation\_spoke\_arn](#output\_cloudformation\_spoke\_arn) | The ARN for the spoke cloudformation scheduler template |
| <a name="output_cloudformation_spoke_url"></a> [cloudformation\_spoke\_url](#output\_cloudformation\_spoke\_url) | The URL for the spoke cloudformation scheduler template |
| <a name="output_scheduler_dynamodb_table"></a> [scheduler\_dynamodb\_table](#output\_scheduler\_dynamodb\_table) | The DynamoDB table to use for the scheduler |
| <a name="output_scheduler_role_arn"></a> [scheduler\_role\_arn](#output\_scheduler\_role\_arn) | The role arn of the scheduler |
| <a name="output_scheduler_sns_issue_topic_arn"></a> [scheduler\_sns\_issue\_topic\_arn](#output\_scheduler\_sns\_issue\_topic\_arn) | The SNS topic to use for the scheduler |
<!-- END_TF_DOCS -->
