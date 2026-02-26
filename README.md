<!-- markdownlint-disable -->

<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-instance-scheduler/blob/main/appvia_banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/instance-scheduler/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-instance-scheduler/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-instance-scheduler.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-instance-scheduler/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-instance-scheduler.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-instance-scheduler/actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler

This repository packages AWS Instance Scheduler into composable Terraform modules for hub-and-spoke platforms. It solves the problem of inconsistent runtime controls across accounts by standardizing schedule deployment, schedule data management, and tag enforcement as code.

In a typical landing zone setup, `modules/scheduler` runs in a central account, `modules/config` manages periods/schedules in DynamoDB, and `modules/tagging` backfills missing schedule tags. For spoke onboarding there are now two explicit options: `modules/spoke` for standalone deployment into a single target account, and `modules/spokes` for organizational deployment via CloudFormation StackSets across multiple accounts/OUs. `modules/macro` can inject default tags into CloudFormation resources through a transform.

## Capabilities

- **Security by default**: S3 template buckets enforce TLS, block insecure uploads, require encryption, and enable versioning.
- **Cross-account operations**: Supports centralized scheduling patterns with AWS Organizations and StackSets for multi-account rollout.
- **Operational excellence**: Separates scheduler deployment from schedule data so teams can iterate schedules without replacing the scheduler stack.
- **Flexible tagging controls**: Provides scheduled Lambda-based tag enforcement for EC2, Auto Scaling, RDS, Aurora, DocumentDB, and Neptune.
- **Cloud platform alignment**: Designed for AWS landing zone patterns with hub account orchestration and spoke account execution.
- **Compliance support**: Helps implement cost-control and governance objectives that commonly map to SOC 2, ISO 27001, and PCI-DSS operating controls.

## Usage Gallery

### Golden Path (Simple)

Deploy the scheduler in a central account and define one business-hours schedule.

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

  scheduler_tag_name         = "Schedule"
  scheduler_regions          = ["eu-west-2"]
  scheduler_organizations_ids = ["o-abc123xyz0"]
  scheduler_frequency        = 15
  tags                       = local.tags
}

module "config" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/config?ref=main"

  dyanmodb_table_name = module.scheduler.scheduler_dynamodb_table

  periods = {
    office_hours = {
      description = "Weekday operating window"
      start_time  = "08:00"
      end_time    = "18:00"
      weekdays    = ["mon-fri"]
    }
  }

  schedules = {
    office_hours = {
      description = "Run only in office hours"
      periods     = ["office_hours"]
      timezone    = "Europe/London"
    }
  }
}
```

### Power User (Advanced)

Enable broader resource coverage, explicit security inputs, and centralized tag enforcement across resource classes.

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

  cloudformation_bucket_name       = "org-prod-instance-scheduler-templates"
  enable_cloudformation_macro      = true
  enable_cloudwatch_dashboard      = true
  enable_ssm_maintenance_windows   = true
  enable_rds_snapshot              = true
  scheduler_tag_name               = "Schedule"
  scheduler_regions                = ["eu-west-2", "eu-central-1"]
  scheduler_organizations_ids      = ["o-abc123xyz0"]
  scheduler_log_group_retention    = "30"
  scheduler_timezone               = "UTC"
  kms_key_arns                     = ["arn:aws:kms:eu-west-2:111122223333:key/abcd-1234"]
  tags                             = local.tags
}

module "spokes" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spokes?ref=main"

  scheduler_account_id = "111122223333"
  organizational_units = {
    engineering = "ou-abcd-11111111"
    data        = "ou-abcd-22222222"
  }
  tags = local.tags
}

module "tagging" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/tagging?ref=main"

  scheduler_tag_name  = "Schedule"
  scheduler_tag_value = "office_hours"
  schedule            = "rate(15 minutes)"
  enable_autoscaling  = true
  enable_ec2          = true
  enable_rds          = true
  autoscaling = {
    excluded_tags = ["DoNotSchedule=true"]
  }
  tags = local.tags
}
```

## Known Limitations

- CloudFormation stack and StackSet updates are asynchronous and can take several minutes before full rollout completes.
- S3 bucket names are globally unique; naming conventions must avoid collisions across AWS accounts.
- Scheduler frequency is constrained to supported values (`1, 2, 5, 10, 15, 30, 60` minutes).
- `modules/config` writes directly to the scheduler DynamoDB table; name collisions in `periods`/`schedules` overwrite existing items.
- Choose `modules/spoke` for single-account onboarding and `modules/spokes` for OU-based multi-account onboarding via StackSets.

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (<https://terraform-docs.io/user-guide/installation/>)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
