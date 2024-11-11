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
| <a name="input_scheduler_tag_value"></a> [scheduler\_tag\_value](#input\_scheduler\_tag\_value) | The value of the tag that will be applied to resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the resources | `map(string)` | n/a | yes |
| <a name="input_aurora"></a> [aurora](#input\_aurora) | Configuration for the Aurora clusters to tag | <pre>object({<br/>    excluded_tags = optional(list(string), [])<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    schedule = optional(string, null)<br/>    # Override the default schedule if provided<br/>  })</pre> | `{}` | no |
| <a name="input_autoscaling"></a> [autoscaling](#input\_autoscaling) | Configuration for the autoscaling groups to tag | <pre>object({<br/>    excluded_tags = optional(list(string), [])<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    schedule = optional(string, null)<br/>    # Override the default schedule if provided<br/>    scheduler_tag_name = optional(string, null)<br/>    # Override the default scheduler_tag_name if provided<br/>    scheduler_tag_value = optional(string, null)<br/>    # Override the default scheduler_tag_value if provided<br/>  })</pre> | <pre>{<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_documentdb"></a> [documentdb](#input\_documentdb) | Configuration for the DocumentDB clusters to tag | <pre>object({<br/>    excluded_tags = optional(list(string), [])<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    schedule = optional(string, null)<br/>    # Override the default schedule if provided<br/>  })</pre> | <pre>{<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_ec2"></a> [ec2](#input\_ec2) | Configuration for the EC2 instances to tag | <pre>object({<br/>    excluded_tags = optional(list(string), [])<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    schedule = optional(string, null)<br/>    # Override the default schedule if provided<br/>  })</pre> | <pre>{<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_enable_aurora"></a> [enable\_aurora](#input\_enable\_aurora) | Whether Aurora clusters should be tagged | `bool` | `false` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether autoscaling groups should be tagged | `bool` | `false` | no |
| <a name="input_enable_debug"></a> [enable\_debug](#input\_enable\_debug) | Whether debug logging should be enabled for the lambda function | `bool` | `false` | no |
| <a name="input_enable_documentdb"></a> [enable\_documentdb](#input\_enable\_documentdb) | Whether DocumentDB clusters should be tagged | `bool` | `false` | no |
| <a name="input_enable_ec2"></a> [enable\_ec2](#input\_enable\_ec2) | Whether EC2 instances should be tagged | `bool` | `false` | no |
| <a name="input_enable_neptune"></a> [enable\_neptune](#input\_enable\_neptune) | Whether Neptune clusters should be tagged | `bool` | `false` | no |
| <a name="input_enable_rds"></a> [enable\_rds](#input\_enable\_rds) | Whether RDS instances should be tagged | `bool` | `false` | no |
| <a name="input_eventbridge_rule_name_prefix"></a> [eventbridge\_rule\_name\_prefix](#input\_eventbridge\_rule\_name\_prefix) | The name of the eventbridge rule that will trigger the lambda function | `string` | `"lza-scheduler-tagging"` | no |
| <a name="input_lambda_execution_role_name_prefix"></a> [lambda\_execution\_role\_name\_prefix](#input\_lambda\_execution\_role\_name\_prefix) | The name of the IAM role that will be created for the lambda function | `string` | `"lza-scheduler-tagging"` | no |
| <a name="input_lambda_function_name_prefix"></a> [lambda\_function\_name\_prefix](#input\_lambda\_function\_name\_prefix) | The name of the lambda function that will be created | `string` | `"lza-scheduler-tagging"` | no |
| <a name="input_lambda_log_retention"></a> [lambda\_log\_retention](#input\_lambda\_log\_retention) | The number of days to retain the logs for the lambda function | `number` | `7` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | The amount of memory in MB allocated to the lambda function | `number` | `128` | no |
| <a name="input_lambda_policy_name_prefix"></a> [lambda\_policy\_name\_prefix](#input\_lambda\_policy\_name\_prefix) | The name of the IAM policy that will be created for the lambda function | `string` | `"lza-scheduler-tagging"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | The amount of time in seconds before the lambda function times out | `number` | `10` | no |
| <a name="input_neptune"></a> [neptune](#input\_neptune) | Configuration for the Neptune clusters to tag | <pre>object({<br/>    excluded_tags = optional(list(string), [])<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    schedule = optional(string, null)<br/>    # Override the default schedule if provided<br/>  })</pre> | `{}` | no |
| <a name="input_rds"></a> [rds](#input\_rds) | Configuration for the RDS instances to tag | <pre>object({<br/>    excluded_tags = optional(list(string), [])<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    schedule = optional(string, null)<br/>    # Override the default schedule if provided<br/>  })</pre> | `{}` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The schedule expression that will trigger the lambda function | `string` | `"cron(0/15 * * * ? *)"` | no |
| <a name="input_scheduler_tag_name"></a> [scheduler\_tag\_name](#input\_scheduler\_tag\_name) | The name of the tag that will be applied to resources | `string` | `"Schedule"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
