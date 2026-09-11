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
    condition     = one([for q in aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].metric_query : q.metric[0].period if q.id == "invocations"]) == 3600 && aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].treat_missing_data == "breaching"
    error_message = "The heartbeat alarm should use the scheduler frequency as its period and treat missing data as breaching"
  }

  assert {
    condition     = one([for q in aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].metric_query : q.expression if q.id == "invocations_filled"]) == "FILL(invocations, 0)"
    error_message = "The heartbeat alarm must fill missing periods with zero so a stopped scheduler is not masked by lookback data"
  }

  assert {
    condition     = aws_cloudwatch_log_metric_filter.application_errors["administrative"].pattern == "{ ($.level = \"ERROR\") || ($.level = \"CRITICAL\") }"
    error_message = "The application-errors filter pattern must match ERROR or CRITICAL level events"
  }

  assert {
    condition     = aws_cloudwatch_log_metric_filter.invocation_failures["administrative"].pattern == "{ ($.type = \"platform.report\") && ($.record.status != \"success\") }"
    error_message = "The invocation-failures filter pattern must match non-success platform.report events"
  }

  assert {
    condition     = aws_cloudwatch_log_metric_filter.scheduling_invocations[0].pattern == "{ $.type = \"platform.report\" }"
    error_message = "The scheduling-invocations filter pattern must match every platform.report event"
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
    condition     = one([for q in aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].metric_query : q.metric[0].period if q.id == "invocations"]) == 300
    error_message = "The heartbeat period should be floored at five minutes"
  }
}

run "observability_rejects_invalid_topic" {
  command = plan

  module {
    source = "./modules/scheduler"
  }

  variables {
    enable_observability        = true
    observability_sns_topic_arn = ""
  }

  expect_failures = [
    var.observability_sns_topic_arn,
  ]
}

run "observability_custom_stack_name" {
  command = plan

  module {
    source = "./modules/scheduler"
  }

  variables {
    enable_observability          = true
    observability_sns_topic_arn   = "arn:aws:sns:eu-west-2:123456789012:alerts"
    cloudformation_hub_stack_name = "custom-scheduler"
  }

  assert {
    condition     = aws_cloudwatch_log_metric_filter.application_errors["administrative"].log_group_name == "custom-scheduler-default-administrative-logs" && aws_cloudwatch_log_metric_filter.application_errors["scheduling"].log_group_name == "custom-scheduler-default-scheduling-logs"
    error_message = "Metric filters must target the log groups derived from the custom stack name"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.application_errors["administrative"].alarm_name == "custom-scheduler-administrative-application-errors"
    error_message = "The application-errors alarm name must be derived from the custom stack name"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.invocation_failures["scheduling"].alarm_name == "custom-scheduler-scheduling-invocation-failures"
    error_message = "The invocation-failures alarm name must be derived from the custom stack name"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.scheduler_heartbeat[0].alarm_name == "custom-scheduler-scheduler-heartbeat"
    error_message = "The heartbeat alarm name must be derived from the custom stack name"
  }

  assert {
    condition     = aws_cloudwatch_log_metric_filter.application_errors["administrative"].metric_transformation[0].namespace == "custom-scheduler/Observability"
    error_message = "The metric filter namespace must be derived from the custom stack name"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.application_errors["administrative"].namespace == "custom-scheduler/Observability"
    error_message = "The error alarm namespace must be derived from the custom stack name"
  }
}
