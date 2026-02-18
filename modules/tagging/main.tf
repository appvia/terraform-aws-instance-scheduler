
## Configure the Lambda function for the tagging process of the resource
module "lambda_function" {
  for_each = local.resources_in_scope_all
  source   = "terraform-aws-modules/lambda/aws"
  version  = "8.7.0"

  create_package = true
  description    = "Automatically tags RDS instances with a 'Schedule' tag if missing"
  function_name  = format("%s-%s", var.lambda_function_name_prefix, each.key)
  function_tags  = var.tags
  handler        = format("%s.lambda_handler", each.key)
  hash_extra     = each.key
  memory_size    = var.lambda_memory_size
  runtime        = "python3.9"
  source_path    = format("%s/assets/functions/%s.py", path.module, each.key)
  tags           = var.tags
  timeout        = var.lambda_timeout

  ## The role that the Lambda function will assume
  create_role      = true
  role_name        = format("%s-%s", var.lambda_execution_role_name_prefix, each.key)
  role_path        = "/"
  role_description = format("Used to automatically tag %s resources missing schedule tags", each.key)
  role_tags        = var.tags

  ## The policy providing the permissions to the Lambda function
  attach_policy_json = true
  policy_json        = each.value.execution_policy

  ## We are using the log group created above to ensure we control the
  ## configuration and the retention period of the logs
  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_log_group_class   = "STANDARD"
  cloudwatch_logs_retention_in_days = var.lambda_log_retention
  cloudwatch_logs_skip_destroy      = false
  cloudwatch_logs_tags              = var.tags

  ## Envionment variables for the Lambda function
  environment_variables = {
    DEBUG              = var.enable_debug ? "True" : "False"
    EXCLUDE_TAG_KEYS   = join(",", each.value.excluded_tags)
    SCHEDULE_TAG_NAME  = coalesce(each.value.tag_name, var.scheduler_tag_name)
    SCHEDULE_TAG_VALUE = coalesce(each.value.tag_value, var.scheduler_tag_value)
  }
}

## CloudWatch EventBridge rule to trigger the Lambda function on a schedule
resource "aws_cloudwatch_event_rule" "invoke_lambda" {
  for_each = local.resources_in_scope_all

  name                = format("%s-%s", var.eventbridge_rule_name_prefix, each.key)
  description         = "Used the trigger the Lambda function to tag resources"
  schedule_expression = coalesce(each.value.schedule, var.schedule)
  tags                = var.tags
}

## Connect the EventBridge rule to the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  for_each = local.resources_in_scope_all

  rule = aws_cloudwatch_event_rule.invoke_lambda[each.key].name
  arn  = module.lambda_function[each.key].lambda_function_arn
}

## Allow EventBridge to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  for_each = local.resources_in_scope_all

  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function[each.key].lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_lambda[each.key].arn
  statement_id  = "AllowExecutionFromEventBridge"
}
