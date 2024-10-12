
## Get the current session
data "aws_caller_identity" "current" {
  provider = aws.hub
}

## Get the current region 
data "aws_region" "current" {
  provider = aws.hub
}
