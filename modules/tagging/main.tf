
## Configure a role for the Lambda function to run under
resource "aws_iam_role" "lambda_execution_role" {
  for_each = local.resources_in_scope_all

  name = format("%s-%s", var.lambda_execution_role_name_prefix, each.key)
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

## Attach a policy to the Lambda execution role
resource "aws_iam_policy" "lambda_policy" {
  for_each = local.resources_in_scope_all

  name   = format("%s-%s", var.lambda_policy_name_prefix, each.key)
  policy = each.value.execution_policy
}

## Attach the policy to the lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  for_each = local.resources_in_scope_all

  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = aws_iam_policy.lambda_policy[each.key].arn
}

## Configure the Lambda function for the tagging process of the resource
module "lambda_function" {
  for_each = local.resources_in_scope_all
  source   = "terraform-aws-modules/lambda/aws"
  version  = "7.14.0"

  create_package = true
  description    = "Automatically tags RDS instances with a 'Schedule' tag if missing"
  function_name  = format("%s-%s", var.lambda_function_name_prefix, each.key)
  handler        = "lambda_function.lambda_handler"
  memory_size    = var.lambda_memory_size
  runtime        = "python3.9"
  source_path    = format("%s/assets/function/%s.py", path.module, each.key)
  tags           = var.tags
  timeout        = var.lambda_timeout

  ## We are using the log group created above to ensure we control the 
  ## configuration and the retention period of the logs
  cloudwatch_logs_log_group_class   = "STANDARD"
  cloudwatch_logs_retention_in_days = var.lambda_log_retention
  cloudwatch_logs_skip_destroy      = false

  ## Envionment variables for the Lambda function
  environment_variables = {
    DEBUG              = var.enable_debug ? "True" : "False"
    EXCLUDE_TAG_KEYS   = each.value.excluded_tags
    SCHEDULE_TAG_NAME  = each.value.tag_name
    SCHEDULE_TAG_VALUE = each.value.tag_value
  }
}

## CloudWatch EventBridge rule to trigger the Lambda function on a schedule
resource "aws_cloudwatch_event_rule" "invoke_lambda" {
  for_each = local.resources_in_scope_all

  name                = format("%s-%s", var.eventbridge_rule_name_prefix, each.key)
  description         = "Used the trigger the Lambda function to tag resources"
  schedule_expression = each.value.schedule
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

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function[each.key].lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_lambda[each.key].arn
}
