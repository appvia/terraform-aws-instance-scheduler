locals {
  # The account ID and region
  account_id = data.aws_caller_identity.current.account_id
  # The region
  region = data.aws_region.current.name
  # The name of the CloudWatch log group
  cloudwatch_log_group_name = format("/aws/lambda/%s-cloudformation-macro", var.name_prefix)
  # The name of the Lambda function
  lambda_function_name = format("%s-cloudformation", var.name_prefix)
  # The name of the IAM role
  iam_role_name = format("%s-cloudformation", var.name_prefix)
  # The name of the IAM role policy
  iam_role_policy_name = format("%s-cloudformation", var.name_prefix)
  # We need to convert the map(string) tags to a list of Key/Value pairs
  default_tags = [for k, v in var.tags : { Key = k, Value = v }]
}
