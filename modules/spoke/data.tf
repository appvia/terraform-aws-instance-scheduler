## Get the current session
data "aws_caller_identity" "current" {}
## Get the current region
data "aws_region" "current" {}
