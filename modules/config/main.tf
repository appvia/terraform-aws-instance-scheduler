
## Provision the period in the dynamodb table 
resource "aws_dynamodb_table_item" "periods" {
  for_each = var.periods

  hash_key   = data.aws_dynamodb_table.table.hash_key
  range_key  = data.aws_dynamodb_table.table.range_key
  table_name = data.aws_dynamodb_table.table.name

  item = templatefile("${path.module}/assets/period.json", {
    description = each.value.description,
    end_time    = each.value.end_time,
    months      = each.value.months,
    name        = each.key,
    start_time  = each.value.start_time,
    weekdays    = each.value.weekdays,
  })
}

## Provision the schedules in the dynamodb table 
resource "aws_dynamodb_table_item" "schedules" {
  for_each = var.schedules

  hash_key   = data.aws_dynamodb_table.table.hash_key
  range_key  = data.aws_dynamodb_table.table.range_key
  table_name = data.aws_dynamodb_table.table.name

  item = templatefile("${path.module}/assets/schedule.json", {
    description     = each.value.description,
    name            = each.key,
    override_status = each.value.override_status,
    periods         = each.value.periods,
    timezone        = each.value.timezone,
  })
}
