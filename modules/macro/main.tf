## Trust IAM policy for the Lambda function
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

## IAM policy to allow the Lambda function to log to CloudWatch
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.cloudwatch_log_group_name}:*"]
  }
}

## Provision the IAM role for the Lambda function
resource "aws_iam_role" "current" {
  name               = local.iam_role_name
  description        = "IAM role used to allow the Lambda function to access AWS services"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}

## Provision the IAM policy for CloudWatch Logs
resource "aws_iam_role_policy" "current" {
  name   = local.iam_role_policy_name
  policy = data.aws_iam_policy_document.cloudwatch.json
  role   = aws_iam_role.current.id
}

## Provision the cloud
resource "aws_cloudwatch_log_group" "current" {
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id
  tags              = var.tags
}

## Provision the Lambda function
resource "aws_lambda_function" "current" {
  architectures    = [var.architecture]
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = local.lambda_function_name
  role             = aws_iam_role.current.arn
  handler          = "handler.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags             = var.tags

  environment {
    variables = {
      DEFAULT_TAGS = jsonencode(local.default_tags)
    }
  }
}

## Lambda permission to allow CloudFormation to invoke the function
resource "aws_lambda_permission" "allow_cloudformation" {
  statement_id  = "AllowExecutionFromCloudFormation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.current.function_name
  principal     = "cloudformation.amazonaws.com"
}

# CloudFormation Transform (Macro)
resource "aws_cloudformation_stack" "current" {
  name = var.cloudformation_transform_name
  tags = var.tags

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Transform                = "AWS::Serverless-2016-10-31"
    Resources = {
      TransformFunction = {
        Type = "AWS::CloudFormation::Macro"
        Properties = {
          Name         = "${var.name_prefix}-default-tags-macro"
          Description  = "Macro to add default tags to CloudFormation resources"
          FunctionName = aws_lambda_function.current.arn
        }
      }
    }
  })
}
