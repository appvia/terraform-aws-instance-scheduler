![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler Config

This module manages scheduler configuration data as Terraform state. It solves the problem of schedule drift by writing periods and schedules directly to the existing Instance Scheduler DynamoDB table, so runtime windows are version-controlled and reviewable in pull requests.

In a hub-and-spoke landing zone, this module typically runs alongside `modules/scheduler`: the scheduler stack exposes the table name, and `modules/config` owns the schedule catalog consumed by resource tags.

## Capabilities

- **Infrastructure as code schedules**: Creates DynamoDB items for `periods` and `schedules` using Terraform resources.
- **Flexible time modeling**: Supports reusable period definitions with weekdays, months, time windows, and timezone selection.
- **Operational separation**: Decouples scheduler infrastructure lifecycle from schedule policy updates.
- **Cloud landing zone alignment**: Fits centralized multi-account scheduler patterns where governance teams manage policy centrally.
- **Compliance support**: Improves traceability for uptime and shutdown policies often needed for SOC 2 and ISO 27001 evidence.

## Usage Gallery

### Golden Path (Simple)

```hcl
module "config" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/config?ref=main"

  dyanmodb_table_name = "lza-instance-scheduler-config"

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
      description = "Run workloads in office hours"
      periods     = ["office_hours"]
      timezone    = "Europe/London"
    }
  }
}
```

### Power User (Advanced)

```hcl
module "config" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/config?ref=main"

  dyanmodb_table_name = "lza-instance-scheduler-config"

  periods = {
    trading_open = {
      description = "Daily market opening period"
      start_time  = "06:30"
      end_time    = "16:30"
      weekdays    = ["mon-fri"]
      months      = ["jan-dec"]
    }
    month_end_extension = {
      description = "Month-end close extension"
      start_time  = "16:30"
      end_time    = "20:00"
      weekdays    = ["fri"]
      months      = ["jan-dec"]
    }
  }

  schedules = {
    finance_prod = {
      description        = "Finance production runtime windows"
      periods            = ["trading_open", "month_end_extension"]
      timezone           = "Europe/London"
      enforced           = true
      stop_new_instances = true
    }
  }
}
```

### Migration (Edge Case)

```hcl
module "config" {
  source = "github.com/appvia/terraform-aws-instance-scheduler//modules/config?ref=main"

  dyanmodb_table_name = "legacy-instance-scheduler-config"

  periods = {
    legacy_shift = {
      description = "Existing legacy shift period"
      start_time  = "07:00"
      end_time    = "19:00"
      weekdays    = ["mon-fri"]
    }
  }

  schedules = {
    legacy_shift = {
      description     = "Mapped to existing resource tag values"
      periods         = ["legacy_shift"]
      timezone        = "UTC"
      override_status = "running"
    }
  }
}
```

## Known Limitations

- The target DynamoDB table must already exist and be accessible from the AWS provider credentials in use.
- Entries are keyed by schedule/period names; reusing names updates existing items rather than creating parallel versions.
- This module does not validate semantic correctness of schedule combinations beyond Terraform type checks.
- Changes apply in-place to live scheduler configuration, so rollout sequencing across environments is important.

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
| <a name="input_dyanmodb_table_name"></a> [dyanmodb\_table\_name](#input\_dyanmodb\_table\_name) | The name of the DynamoDB table to use for the scheduler | `string` | n/a | yes |
| <a name="input_periods"></a> [periods](#input\_periods) | A period to create with the instance scheduler | <pre>map(object({<br/>    # A human-readable description of the period<br/>    description = string<br/>    # The end time of the period<br/>    end_time = optional(string, null)<br/>    # The months to apply to the period<br/>    months = optional(list(string), null)<br/>    # The start time of the period<br/>    start_time = optional(string, null)<br/>    # The weekdays to apply to the period<br/>    weekdays = optional(list(string), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | The schedule to create within the scheduler | <pre>map(object({<br/>    # A human-readable description of the schedule<br/>    description = string<br/>    # Whether the schedule is enforced<br/>    enforced = optional(bool, null)<br/>    # The status to set when the schedule is enforced<br/>    override_status = optional(string, null)<br/>    # The periods to apply to the schedule<br/>    periods = list(string)<br/>    # Whether to stop new instances<br/>    stop_new_instances = optional(bool, null)<br/>    # The timezone to use for the schedule<br/>    timezone = optional(string, "UTC")<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
