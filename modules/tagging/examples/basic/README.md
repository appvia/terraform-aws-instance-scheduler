## Tagging Example

This example demonstrates automated schedule-tag enforcement for resources that are in scope but missing scheduler tags. It helps platform teams keep scheduler behavior predictable even when application teams provision resources without required tags.

## Capabilities Demonstrated

- EventBridge-triggered Lambda tagging loop.
- Per-resource-type enablement and exclusion controls.
- Central tagging policy pattern for AWS landing zone environments.

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
  source = "../../"

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
  source = "../../"

  scheduler_tag_name  = "Schedule"
  scheduler_tag_value = "office_hours"
  schedule            = "rate(10 minutes)"
  enable_debug        = true

  enable_autoscaling = true
  enable_ec2         = true
  enable_rds         = true

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
  source = "../../"

  scheduler_tag_name  = "InstanceSchedule"
  scheduler_tag_value = "legacy-shift"
  schedule            = "rate(30 minutes)"
  enable_autoscaling  = true

  autoscaling = {
    excluded_tags       = ["ManagedBy=legacy-orchestrator"]
    scheduler_tag_name  = "legacy-schedule"
    scheduler_tag_value = "legacy-shift"
  }

  tags = local.tags
}
```

## Known Limitations

- Tag enforcement is periodic, so there can be delay before newly created resources are corrected.
- Exclusion filters are string-based (`key=value`) and should be validated carefully to avoid accidental scope gaps.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_cloudwatch_logs_group_arns"></a> [lambda\_cloudwatch\_logs\_group\_arns](#output\_lambda\_cloudwatch\_logs\_group\_arns) | List of the CloudWatch log group ARNs for the Lambda functions |
| <a name="output_lambda_cloudwatch_logs_group_names"></a> [lambda\_cloudwatch\_logs\_group\_names](#output\_lambda\_cloudwatch\_logs\_group\_names) | List of the CloudWatch log group names for the Lambda functions |
| <a name="output_lambda_function_arns"></a> [lambda\_function\_arns](#output\_lambda\_function\_arns) | List of the Lambda function ARNs |
| <a name="output_lambda_iam_role_arns"></a> [lambda\_iam\_role\_arns](#output\_lambda\_iam\_role\_arns) | List of the IAM role ARNs for the Lambda functions |
| <a name="output_lambda_iam_role_names"></a> [lambda\_iam\_role\_names](#output\_lambda\_iam\_role\_names) | List of the IAM role names for the Lambda functions |
| <a name="output_resources_in_scope"></a> [resources\_in\_scope](#output\_resources\_in\_scope) | A map of the resources which are going to be tagged |
<!-- END_TF_DOCS -->