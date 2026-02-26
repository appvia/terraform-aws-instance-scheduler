![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler

This module enforces scheduler tag hygiene for resources that are missing the schedule tag. It solves a common operations problem in large estates: scheduler policies exist, but resource teams do not always apply the required tag consistently.

Architecture overview:
- For each enabled resource type, the module provisions a dedicated Lambda function with scoped permissions.
- EventBridge schedules invoke each function on a cadence you define.
- Each function discovers resources, skips excluded-tag matches, and applies the configured scheduler tag when absent.

It is intended for AWS multi-account landing zones where central scheduling policy and delegated application teams coexist.

## Capabilities

- **Security by default**: Per-resource-type IAM execution policies with no static credentials.
- **Flexible enforcement**: Supports independent scheduling and exclusion controls per resource class.
- **Operational excellence**: Event-driven tagging loop provides continuous correction without manual sweeps.
- **Platform breadth**: Covers Auto Scaling, EC2, RDS, Aurora, DocumentDB, and Neptune.
- **Compliance support**: Helps enforce consistent governance tags used in operational controls for SOC 2, ISO 27001, and PCI-DSS programs.

## Usage Gallery

### Golden Path (Simple)

```hcl
locals {
  tags = {
    Environment = "development"
    Owner       = "platform"
  }
}

module "tagging" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/tagging?ref=main"

  scheduler_tag_name  = "Schedule"
  scheduler_tag_value = "office_hours"
  schedule            = "rate(15 minutes)"
  enable_ec2          = true
  tags                = local.tags
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

module "tagging" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/tagging?ref=main"

  scheduler_tag_name  = "Schedule"
  scheduler_tag_value = "office_hours"
  schedule            = "rate(10 minutes)"
  enable_debug        = true

  enable_autoscaling = true
  enable_ec2         = true
  enable_rds         = true
  enable_documentdb  = true

  autoscaling = {
    schedule            = "rate(5 minutes)"
    excluded_tags       = ["DoNotSchedule=true"]
    scheduler_tag_name  = "Schedule"
    scheduler_tag_value = "asg-hours"
  }

  ec2 = {
    excluded_tags = ["Lifecycle=persistent"]
  }

  rds = {
    schedule = "rate(30 minutes)"
  }

  tags = local.tags
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

module "tagging" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/tagging?ref=main"

  scheduler_tag_name  = "InstanceSchedule"
  scheduler_tag_value = "legacy-shift"
  schedule            = "rate(30 minutes)"

  enable_autoscaling = true
  autoscaling = {
    excluded_tags       = ["ManagedBy=legacy-orchestrator"]
    scheduler_tag_name  = "legacy-schedule"
    scheduler_tag_value = "legacy-shift"
  }

  tags = local.tags
}
```

## Known Limitations

- Tagging occurs on a schedule, not instantly; newly created resources are tagged on the next EventBridge execution.
- Exclusion matching expects `key=value` formatted entries in `excluded_tags`.
- This module enforces tag presence, not full schedule validity; ensure referenced schedule values exist in scheduler configuration.
- Large inventories can require tuning invocation cadence and Lambda memory/timeout settings.

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
| <a name="input_scheduler_tag_value"></a> [scheduler\_tag\_value](#input\_scheduler\_tag\_value) | The value of the tag that will be applied to resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the resources | `map(string)` | n/a | yes |
| <a name="input_aurora"></a> [aurora](#input\_aurora) | Configuration for the Aurora clusters to tag | <pre>object({<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    excluded_tags = optional(list(string), [])<br/>    # Override the default schedule if provided<br/>    schedule = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_autoscaling"></a> [autoscaling](#input\_autoscaling) | Configuration for the autoscaling groups to tag | <pre>object({<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    excluded_tags = optional(list(string), [])<br/>    # Override the default schedule if provided<br/>    schedule = optional(string, null)<br/>    # Override the default scheduler_tag_name if provided<br/>    scheduler_tag_name = optional(string, null)<br/>    # Override the default scheduler_tag_value if provided<br/>    scheduler_tag_value = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_documentdb"></a> [documentdb](#input\_documentdb) | Configuration for the DocumentDB clusters to tag | <pre>object({<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    excluded_tags = optional(list(string), [])<br/>    # Override the default schedule if provided<br/>    schedule = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_ec2"></a> [ec2](#input\_ec2) | Configuration for the EC2 instances to tag | <pre>object({<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    excluded_tags = optional(list(string), [])<br/>    # Override the default schedule if provided<br/>    schedule = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_enable_aurora"></a> [enable\_aurora](#input\_enable\_aurora) | Whether Aurora clusters should be tagged | `bool` | `false` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether autoscaling groups should be tagged | `bool` | `false` | no |
| <a name="input_enable_debug"></a> [enable\_debug](#input\_enable\_debug) | Whether debug logging should be enabled for the lambda function | `bool` | `false` | no |
| <a name="input_enable_documentdb"></a> [enable\_documentdb](#input\_enable\_documentdb) | Whether DocumentDB clusters should be tagged | `bool` | `false` | no |
| <a name="input_enable_ec2"></a> [enable\_ec2](#input\_enable\_ec2) | Whether EC2 instances should be tagged | `bool` | `false` | no |
| <a name="input_enable_neptune"></a> [enable\_neptune](#input\_enable\_neptune) | Whether Neptune clusters should be tagged | `bool` | `false` | no |
| <a name="input_enable_rds"></a> [enable\_rds](#input\_enable\_rds) | Whether RDS instances should be tagged | `bool` | `false` | no |
| <a name="input_eventbridge_rule_name_prefix"></a> [eventbridge\_rule\_name\_prefix](#input\_eventbridge\_rule\_name\_prefix) | The name of the eventbridge rule that will trigger the lambda function | `string` | `"lza-scheduler-tagging"` | no |
| <a name="input_lambda_execution_role_name_prefix"></a> [lambda\_execution\_role\_name\_prefix](#input\_lambda\_execution\_role\_name\_prefix) | The name of the IAM role that will be created for the lambda function | `string` | `"lza-scheduler-tagging"` | no |
| <a name="input_lambda_function_name_prefix"></a> [lambda\_function\_name\_prefix](#input\_lambda\_function\_name\_prefix) | The name of the lambda function | `string` | `"lza-scheduler-tagging"` | no |
| <a name="input_lambda_log_retention"></a> [lambda\_log\_retention](#input\_lambda\_log\_retention) | The number of days to retain the logs for the lambda function | `number` | `7` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | The amount of memory in MB allocated to the lambda function | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | The amount of time in seconds before the lambda function times out | `number` | `10` | no |
| <a name="input_neptune"></a> [neptune](#input\_neptune) | Configuration for the Neptune clusters to tag | <pre>object({<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    excluded_tags = optional(list(string), [])<br/>    # Override the default schedule if provided<br/>    schedule = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_rds"></a> [rds](#input\_rds) | Configuration for the RDS instances to tag | <pre>object({<br/>    # List of tags on resources that should be excluded from the tagging process<br/>    excluded_tags = optional(list(string), [])<br/>    # Override the default schedule if provided<br/>    schedule = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The schedule expression that will trigger the lambda function | `string` | `"cron(0/15 * * * ? *)"` | no |
| <a name="input_scheduler_tag_name"></a> [scheduler\_tag\_name](#input\_scheduler\_tag\_name) | The name of the tag that will be applied to resources | `string` | `"Schedule"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_cloudwatch_logs_group_arns"></a> [lambda\_cloudwatch\_logs\_group\_arns](#output\_lambda\_cloudwatch\_logs\_group\_arns) | A list of the CloudWatch log group ARNs for the Lambda functions |
| <a name="output_lambda_cloudwatch_logs_group_names"></a> [lambda\_cloudwatch\_logs\_group\_names](#output\_lambda\_cloudwatch\_logs\_group\_names) | A list of the CloudWatch log group names for the Lambda functions |
| <a name="output_lambda_function_arns"></a> [lambda\_function\_arns](#output\_lambda\_function\_arns) | The Lambda function resources |
| <a name="output_lambda_iam_role_arns"></a> [lambda\_iam\_role\_arns](#output\_lambda\_iam\_role\_arns) | The IAM role ARNs for the Lambda functions |
| <a name="output_lambda_iam_role_names"></a> [lambda\_iam\_role\_names](#output\_lambda\_iam\_role\_names) | A list of the IAM role names for the Lambda functions |
| <a name="output_resources_in_scope"></a> [resources\_in\_scope](#output\_resources\_in\_scope) | A map of the resources which are going to be tagged |
<!-- END_TF_DOCS -->
