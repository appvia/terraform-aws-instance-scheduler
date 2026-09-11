mock_provider "aws" {}

variables {
  enable_cloudformation_macro = false
  organizational_id           = "o-abc123xyz0"
  scheduler_tag_name          = "Schedule"
  tags                        = {}
}

run "observability_disabled_by_default" {
  command = plan

  module {
    source = "./modules/scheduler"
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.application_errors) == 0 && length(aws_cloudwatch_log_metric_filter.invocation_failures) == 0 && length(aws_cloudwatch_log_metric_filter.scheduling_invocations) == 0
    error_message = "No metric filters should be planned when observability is disabled"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.application_errors) == 0 && length(aws_cloudwatch_metric_alarm.invocation_failures) == 0 && length(aws_cloudwatch_metric_alarm.scheduler_heartbeat) == 0
    error_message = "No alarms should be planned when observability is disabled"
  }
}

run "observability_enabled" {
  command = plan

  module {
    source = "./modules/scheduler"
  }

  variables {
    enable_observability        = true
    observability_sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:alerts"
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.application_errors) == 2 && length(aws_cloudwatch_log_metric_filter.invocation_failures) == 2 && length(aws_cloudwatch_log_metric_filter.scheduling_invocations) == 1
    error_message = "Expected five metric filters when observability is enabled"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.application_errors) == 2 && length(aws_cloudwatch_metric_alarm.invocation_failures) == 2 && length(aws_cloudwatch_metric_alarm.scheduler_heartbeat) == 1
    error_message = "Expected five alarms when observability is enabled"
  }

  assert {
    condition     = aws_cloudwatch_log_metric_filter.application_errors["administrative"].log_group_name == "lz-instance-scheduler-hub-default-administrative-logs" && aws_cloudwatch_log_metric_filter.application_errors["scheduling"].log_group_name == "lz-instance-scheduler-hub-default-scheduling-logs"
    error_message = "Metric filters must target the log groups provisioned by the hub stack"
  }

  assert {
    condition = alltrue([
      for alarm in concat(values(aws_cloudwatch_metric_alarm.application_errors), values(aws_cloudwatch_metric_alarm.invocation_failures), aws_cloudwatch_metric_alarm.scheduler_heartbeat) :
      alarm.alarm_actions == toset(["arn:aws:sns:eu-west-2:123456789012:alerts"]) && alarm.ok_actions == toset(["arn:aws:sns:eu-west-2:123456789012:alerts"])
    ])
    error_message = "Every alarm must notify the observability SNS topic on alarm and on recovery"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].period == 3600 && aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].treat_missing_data == "breaching"
    error_message = "The heartbeat alarm should use the scheduler frequency as its period and treat missing data as breaching"
  }
}

run "observability_requires_topic" {
  command = plan

  module {
    source = "./modules/scheduler"
  }

  variables {
    enable_observability = true
  }

  expect_failures = [
    var.observability_sns_topic_arn,
  ]
}

run "observability_without_scheduler" {
  command = plan

  module {
    source = "./modules/scheduler"
  }

  variables {
    enable_observability        = true
    enable_scheduler            = false
    observability_sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:alerts"
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.scheduling_invocations) == 0 && length(aws_cloudwatch_metric_alarm.scheduler_heartbeat) == 0
    error_message = "The heartbeat should not be monitored when the scheduler is disabled"
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.application_errors) == 2 && length(aws_cloudwatch_log_metric_filter.invocation_failures) == 2 && length(aws_cloudwatch_metric_alarm.application_errors) == 2 && length(aws_cloudwatch_metric_alarm.invocation_failures) == 2
    error_message = "Error and failure filters and alarms should still be planned when the scheduler is disabled"
  }
}

run "observability_heartbeat_floor" {
  command = plan

  module {
    source = "./modules/scheduler"
  }

  variables {
    enable_observability        = true
    observability_sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:alerts"
    scheduler_frequency         = 1
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].period == 300
    error_message = "The heartbeat period should be floored at five minutes"
  }
}
