## Config Example

This example demonstrates how to manage scheduler periods and schedules as code once the central scheduler table already exists. It is useful when your platform team wants predictable, reviewable schedule changes instead of ad-hoc CLI updates.

## Capabilities Demonstrated

- Declarative period and schedule creation in the scheduler DynamoDB table.
- Reusable schedule naming that maps directly to workload tags.
- Baseline pattern for centralized schedule governance in AWS landing zones.

## Usage Gallery

### Golden Path (Simple)

```hcl
module "config" {
  source = "../.."

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
  source = "../.."

  dyanmodb_table_name = "lza-instance-scheduler-config"

  periods = {
    trading_window = {
      description = "Trading runtime window"
      start_time  = "06:30"
      end_time    = "16:30"
      weekdays    = ["mon-fri"]
      months      = ["jan-dec"]
    }
    month_end = {
      description = "Month-end extension"
      start_time  = "16:30"
      end_time    = "20:00"
      weekdays    = ["fri"]
    }
  }

  schedules = {
    finance_prod = {
      description        = "Finance runtime policy"
      periods            = ["trading_window", "month_end"]
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
  source = "../.."

  dyanmodb_table_name = "legacy-instance-scheduler-config"

  periods = {
    legacy_shift = {
      description = "Legacy shift period retained during migration"
      start_time  = "07:00"
      end_time    = "19:00"
      weekdays    = ["mon-fri"]
    }
  }

  schedules = {
    legacy_shift = {
      description     = "Compatibility schedule for existing tags"
      periods         = ["legacy_shift"]
      timezone        = "UTC"
      override_status = "running"
    }
  }
}
```

## Known Limitations

- The scheduler table must exist before applying this example.
- Item names are unique keys; reusing names updates existing definitions.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->