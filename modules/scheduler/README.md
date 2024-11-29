![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler

## Description

The Instance Scheduler on AWS solution is an automated solution that schedules Amazon Elastic Compute Cloud (Amazon EC2) and Amazon Relational Database Service (Amazon RDS) instances. The solution enables customers to easily configure custom start and stop schedules for their instances, helping to reduce costs and ensure instances are running only when needed. Deployed centrally within an account, the orchestrator

## Features

- Cross-account instance scheduling

This solution includes a template that creates the AWS Identity and Access Management (IAM) roles necessary to start and stop instances in secondary accounts. For more information, refer to the Cross-account instance scheduling section.

- Automated Tagging

Instance Scheduler on AWS can automatically add tags to all instances that it starts or stops. The solution also includes macros that allow you to add variable information to the tags.

- Configure schedules or periods using Scheduler CLI

This solution includes a command line interface (CLI) that provides commands for configuring schedules and periods. The CLI allows customers to estimate cost savings for a given schedule. For more information, refer to the Scheduler CLI.

- Manage schedules using Infrastructure as Code (IaC)

This solution provides an AWS CloudFormation Custom Resource that you can use to manage schedules using Infrastructure as Code (IaC). For more information, refer to Manage Schedules Using Infrastructure as Code.

- Integration with Systems Manager Maintenance Windows

For Amazon EC2 instances, Instance Scheduler on AWS can integrate with AWS Systems Manager maintenance windows, defined in the same Region as those instances, to start and stop them in accordance with the maintenance window.

- Integration with Service Catalog AppRegistry and Application Manager, a capability of AWS Systems Manager

This solution includes a Service Catalog AppRegistry resource to register the solution's CloudFormation template and its underlying resources as an application in both Service Catalog AppRegistry and Application Manager. With this integration, you can centrally manage the solution's resources.

## Usage

Add example usage here

```hcl
module "example" {
  source  = "appvia/<NAME>/aws"
  version = "0.0.1"

  # insert variables here
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scheduler_tag_name"></a> [scheduler\_tag\_name](#input\_scheduler\_tag\_name) | The tag name used to identify the resources that should be scheduled | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the resources | `map(string)` | n/a | yes |
| <a name="input_cloudformation_bucket_name"></a> [cloudformation\_bucket\_name](#input\_cloudformation\_bucket\_name) | The name of the S3 bucket used to store the cloudformation templates | `string` | `"lza-instance-scheduler-templates"` | no |
| <a name="input_cloudformation_hub_stack_capabilities"></a> [cloudformation\_hub\_stack\_capabilities](#input\_cloudformation\_hub\_stack\_capabilities) | The capabilities required for the cloudformation stack in the hub account | `list(string)` | <pre>[<br/>  "CAPABILITY_NAMED_IAM",<br/>  "CAPABILITY_AUTO_EXPAND",<br/>  "CAPABILITY_IAM"<br/>]</pre> | no |
| <a name="input_cloudformation_hub_stack_name"></a> [cloudformation\_hub\_stack\_name](#input\_cloudformation\_hub\_stack\_name) | The name of the cloudformation stack in the hub account | `string` | `"lza-instance-scheduler-hub"` | no |
| <a name="input_enable_asg_scheduler"></a> [enable\_asg\_scheduler](#input\_enable\_asg\_scheduler) | Whether AutoScaling Groups should under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_cloudwatch_dashboard"></a> [enable\_cloudwatch\_dashboard](#input\_enable\_cloudwatch\_dashboard) | Whether a CloudWatch dashboard used to monitor the scheduler should be created | `bool` | `false` | no |
| <a name="input_enable_debug"></a> [enable\_debug](#input\_enable\_debug) | Whether debug logging should be enabled for the instance scheduler | `bool` | `false` | no |
| <a name="input_enable_docdb_scheduler"></a> [enable\_docdb\_scheduler](#input\_enable\_docdb\_scheduler) | Whether DocumentDB clusters should under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_ec2_scheduler"></a> [enable\_ec2\_scheduler](#input\_enable\_ec2\_scheduler) | Whether EC2 instances should under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_hub_account_scheduler"></a> [enable\_hub\_account\_scheduler](#input\_enable\_hub\_account\_scheduler) | Whether the hub account should be under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_neptune_scheduler"></a> [enable\_neptune\_scheduler](#input\_enable\_neptune\_scheduler) | Whether Neptune clusters should under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_organizational_bucket"></a> [enable\_organizational\_bucket](#input\_enable\_organizational\_bucket) | Indicate we should allow everyone in the organizations access to the cloudformation bucket | `bool` | `false` | no |
| <a name="input_enable_organizations"></a> [enable\_organizations](#input\_enable\_organizations) | Whether the instance scheduler should integrate with AWS Organizations | `bool` | `true` | no |
| <a name="input_enable_rds_cluster_scheduler"></a> [enable\_rds\_cluster\_scheduler](#input\_enable\_rds\_cluster\_scheduler) | Whether RDS clusters should under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_rds_scheduler"></a> [enable\_rds\_scheduler](#input\_enable\_rds\_scheduler) | Whether RDS instances should under the remit of the scheduler | `bool` | `true` | no |
| <a name="input_enable_rds_snapshot"></a> [enable\_rds\_snapshot](#input\_enable\_rds\_snapshot) | Whether RDS instances should have snapshots created on stop | `bool` | `false` | no |
| <a name="input_enable_scheduler"></a> [enable\_scheduler](#input\_enable\_scheduler) | Whether the instance scheduler should be enabled | `bool` | `true` | no |
| <a name="input_enable_ssm_maintenance_windows"></a> [enable\_ssm\_maintenance\_windows](#input\_enable\_ssm\_maintenance\_windows) | Whether EC2 instances should be managed by SSM Maintenance Windows | `bool` | `false` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | The KMS key ARNs used to encrypt the instance scheduler data | `list(string)` | `[]` | no |
| <a name="input_organizational_id"></a> [organizational\_id](#input\_organizational\_id) | The AWS Organization ID used in conjunction with the organizational bucket | `string` | `""` | no |
| <a name="input_scheduler_asg_rule_prefix"></a> [scheduler\_asg\_rule\_prefix](#input\_scheduler\_asg\_rule\_prefix) | The prefix used to identify the AutoScaling Group scheduled actions | `string` | `"is-"` | no |
| <a name="input_scheduler_asg_tag_key"></a> [scheduler\_asg\_tag\_key](#input\_scheduler\_asg\_tag\_key) | The tag key used to identify AutoScaling Groups that should be scheduled | `string` | `"scheduled"` | no |
| <a name="input_scheduler_frequency"></a> [scheduler\_frequency](#input\_scheduler\_frequency) | The frequency at which the instance scheduler should run in minutes | `number` | `60` | no |
| <a name="input_scheduler_log_group_retention"></a> [scheduler\_log\_group\_retention](#input\_scheduler\_log\_group\_retention) | The retention period for the instance scheduler log group | `string` | `"7"` | no |
| <a name="input_scheduler_organizations_ids"></a> [scheduler\_organizations\_ids](#input\_scheduler\_organizations\_ids) | A list of organizations ids that are permitted to use the scheduler | `list(string)` | `[]` | no |
| <a name="input_scheduler_regions"></a> [scheduler\_regions](#input\_scheduler\_regions) | The regions in which the instance scheduler should operate | `list(string)` | `[]` | no |
| <a name="input_scheduler_start_tags"></a> [scheduler\_start\_tags](#input\_scheduler\_start\_tags) | The tags used to identify the resources that should be started | `string` | `"InstanceScheduler-LastAction=Started By {scheduler} {year}/{month}/{day} {hour}:{minute}{timezone},>"` | no |
| <a name="input_scheduler_stop_tags"></a> [scheduler\_stop\_tags](#input\_scheduler\_stop\_tags) | The tags used to identify the resources that should be stopped | `string` | `"InstanceScheduler-LastAction=Stopped By {scheduler} {year}/{month}/{day} {hour}:{minute}{timezone},>"` | no |
| <a name="input_scheduler_timezone"></a> [scheduler\_timezone](#input\_scheduler\_timezone) | The default timezone for the instance scheduler | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id of the scheduler |
| <a name="output_scheduler_dynamodb_table"></a> [scheduler\_dynamodb\_table](#output\_scheduler\_dynamodb\_table) | The DynamoDB table to use for the scheduler |
| <a name="output_scheduler_role_arn"></a> [scheduler\_role\_arn](#output\_scheduler\_role\_arn) | The role arn of the scheduler |
| <a name="output_scheduler_sns_issue_topic_arn"></a> [scheduler\_sns\_issue\_topic\_arn](#output\_scheduler\_sns\_issue\_topic\_arn) | The SNS topic to use for the scheduler |
<!-- END_TF_DOCS -->
