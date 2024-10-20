![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler

## Description

The Instance Scheduler on AWS solution is an automated solution that schedules Amazon Elastic Compute Cloud (Amazon EC2) and Amazon Relational Database Service (Amazon RDS) instances. The solution enables customers to easily configure custom start and stop schedules for their instances, helping to reduce costs and ensure instances are running only when needed. Deployed centrally within an account, the orchestrator

You can find more information about the solution in the [AWS Solutions Implementation Guide](https://docs.aws.amazon.com/solutions/latest/instance-scheduler-on-aws/welcome.html).

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

The following provides an example of how to use the module,

- Firstly we must deploy the orchestrator within the central account.
- Next we can use a stackset, or stack to deploy the resources to the target accounts (spokes).
- Ensure the resources in the account was tagged with the `var.scheduler_tag_name` and the value points to a known schedule definition.

```hcl
locals {
  tags = {
    "Environment" = "Development"
    "Owner"       = "Solutions"
    "Product"     = "LandingZone"
    "Provisioner" = "Terraform"
    "GitRepo"     = "https://github.com/appvia/terraform-aws-instance-scheduler"
  }
}

module "scheduler" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/scheduler?ref=main"

  enable_asg_scheduler            = true
  enable_cloudwatch_dashboard     = false
  enable_cloudwatch_debug_logging = false
  enable_docdb_scheduler          = true
  enable_ec2_scheduler            = true
  enable_hub_account_scheduler    = false
  enable_neptune_scheduler        = false
  enable_organizations            = true
  enable_rds_cluster_scheduler    = true
  enable_rds_scheduler            = true
  enable_rds_snapshot             = false
  enable_scheduler                = true
  tags                            = local.tags

  ## The regions that the scheduler will manage resources in
  scheduler_regions = ["eu-west-2"]
  ## The tag placed on the resources that the scheduler will manage
  ## the lifecycle for based on the schedules and periods defined
  scheduler_tag_name = "Schedule"
  ## Is the interval in minutes that the scheduler will check for resources
  ## that need to be started or stopped
  scheduler_frequency = 5
  ## The organizations id that are permitted to use the scheduler - you can
  ## this detail in the AWS Organizations console
  scheduler_organizations_ids = ["o-7enwqkxxxx"]
}

module "stackset_spoke" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/spoke?ref=main"

  enable_organizations = true
  enable_standalone    = false
  enable_stackset      = true
  region               = "eu-west-2"
  scheduler_account_id = "123456789012"
  tags                 = local.tags

  organizational_units = {
    "infrastructure" = "ou-123456789012"
    "development"    = "ou-123456789013"
  }
}

module "config" {
  source = "../../../config"

  dyanmodb_table_name = module.scheduler.scheduler_dynamodb_table

  periods = {
    "uk_working_hours" = {
      description = "UK Working Hours"
      start_time  = "06:00"
      end_time    = "19:30"
      weekdays    = ["mon-fri"]
    }
  }

  schedules = {
    "uk_working_hours" = {
      description = "Resources will run during the UK working hours, anything outside of this will be stopped"
      periods     = ["uk_working_hours"]
    }
  }

  depends_on = [
    module.scheduler
  ]
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
