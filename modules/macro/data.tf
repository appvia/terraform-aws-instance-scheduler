
# Data source to get the current AWS account ID and region
data "aws_caller_identity" "current" {}

# Data source to get the current AWS region
data "aws_region" "current" {}

# Archive the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/assets"
  output_path = "${path.module}/lambda_function.zip"
}
