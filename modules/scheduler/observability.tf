
## Count the application ERROR and CRITICAL log events within each scheduler log group
resource "aws_cloudwatch_log_metric_filter" "application_errors" {
  for_each = var.enable_observability ? local.observability_log_groups : {}

  name           = format("%s-application-errors", each.value)
  log_group_name = each.value
  pattern        = "{ ($.level = \"ERROR\") || ($.level = \"CRITICAL\") }"

  metric_transformation {
    name      = format("ApplicationErrors-%s", each.key)
    namespace = local.observability_metric_namespace
    value     = "1"
  }

  depends_on = [aws_cloudformation_stack.hub]
}

## Count the lambda invocations which timed out or failed within each scheduler log group
resource "aws_cloudwatch_log_metric_filter" "invocation_failures" {
  for_each = var.enable_observability ? local.observability_log_groups : {}

  name           = format("%s-invocation-failures", each.value)
  log_group_name = each.value
  pattern        = "{ ($.type = \"platform.report\") && ($.record.status != \"success\") }"

  metric_transformation {
    name      = format("InvocationFailures-%s", each.key)
    namespace = local.observability_metric_namespace
    value     = "1"
  }

  depends_on = [aws_cloudformation_stack.hub]
}

## Count the lambda invocations within the scheduling log group, used as the scheduler heartbeat
resource "aws_cloudwatch_log_metric_filter" "scheduling_invocations" {
  count = local.enable_scheduler_heartbeat ? 1 : 0

  name           = format("%s-scheduling-invocations", local.observability_log_groups["scheduling"])
  log_group_name = local.observability_log_groups["scheduling"]
  pattern        = "{ $.type = \"platform.report\" }"

  metric_transformation {
    name      = "SchedulingInvocations"
    namespace = local.observability_metric_namespace
    value     = "1"
  }

  depends_on = [aws_cloudformation_stack.hub]
}

## Alarm when the scheduler logs any application errors
resource "aws_cloudwatch_metric_alarm" "application_errors" {
  for_each = var.enable_observability ? local.observability_log_groups : {}

  alarm_name          = format("%s-%s-application-errors", var.cloudformation_hub_stack_name, each.key)
  alarm_description   = format("The instance scheduler logged ERROR or CRITICAL events, investigate the log group %s", each.value)
  alarm_actions       = [var.observability_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.application_errors[each.key].metric_transformation[0].name
  namespace           = local.observability_metric_namespace
  ok_actions          = [var.observability_sns_topic_arn]
  period              = 300
  statistic           = "Sum"
  tags                = var.tags
  threshold           = 0
  treat_missing_data  = "notBreaching"
}

## Alarm when any scheduler lambda invocation times out or fails
resource "aws_cloudwatch_metric_alarm" "invocation_failures" {
  for_each = var.enable_observability ? local.observability_log_groups : {}

  alarm_name          = format("%s-%s-invocation-failures", var.cloudformation_hub_stack_name, each.key)
  alarm_description   = format("An instance scheduler lambda invocation timed out or failed, investigate the log group %s", each.value)
  alarm_actions       = [var.observability_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.invocation_failures[each.key].metric_transformation[0].name
  namespace           = local.observability_metric_namespace
  ok_actions          = [var.observability_sns_topic_arn]
  period              = 300
  statistic           = "Sum"
  tags                = var.tags
  threshold           = 0
  treat_missing_data  = "notBreaching"
}

## Alarm when the scheduler has not run for two consecutive scheduling periods
resource "aws_cloudwatch_metric_alarm" "scheduler_heartbeat" {
  count = local.enable_scheduler_heartbeat ? 1 : 0

  alarm_name          = format("%s-scheduler-heartbeat", var.cloudformation_hub_stack_name)
  alarm_description   = format("The instance scheduler has not run for two consecutive periods, investigate the log group %s", local.observability_log_groups["scheduling"])
  alarm_actions       = [var.observability_sns_topic_arn]
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 2
  ok_actions          = [var.observability_sns_topic_arn]
  tags                = var.tags
  threshold           = 1
  treat_missing_data  = "breaching"

  metric_query {
    id          = "invocations"
    return_data = false

    metric {
      metric_name = aws_cloudwatch_log_metric_filter.scheduling_invocations[0].metric_transformation[0].name
      namespace   = local.observability_metric_namespace
      period      = local.observability_heartbeat_period
      stat        = "Sum"
    }
  }

  metric_query {
    id          = "invocations_filled"
    expression  = "FILL(invocations, 0)"
    label       = "Scheduling invocations, missing periods filled with zero"
    return_data = true
  }
}
