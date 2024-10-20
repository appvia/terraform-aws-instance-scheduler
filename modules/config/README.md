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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table_item.periods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table_item) | resource |
| [aws_dynamodb_table_item.schedules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table_item) | resource |
| [aws_dynamodb_table.table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/dynamodb_table) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dyanmodb_table_name"></a> [dyanmodb\_table\_name](#input\_dyanmodb\_table\_name) | The name of the DynamoDB table to use for the scheduler | `string` | n/a | yes |
| <a name="input_periods"></a> [periods](#input\_periods) | A period to create with the instance scheduler | <pre>map(object({<br/>    description = string<br/>    end_time    = optional(string, null)<br/>    months      = optional(list(string), null)<br/>    start_time  = optional(string, null)<br/>    weekdays    = optional(list(string), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | The schedule to create within the scheduler | <pre>map(object({<br/>    description     = string<br/>    override_status = optional(string, null)<br/>    periods         = list(string)<br/>    timezone        = optional(string, "UTC")<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
