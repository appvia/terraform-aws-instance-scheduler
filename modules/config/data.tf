
## Find the dynamodb table 
data "aws_dynamodb_table" "table" {
  name = var.dyanmodb_table_name
}
