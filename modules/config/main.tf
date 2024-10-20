
## Provision the period in the dynamodb table 
resource "aws_dynamodb_table_item" "periods" {
  for_each = var.periods

  table_name = data.aws_dynamodb_table.table.name
  hash_key   = data.aws_dynamodb_table.table.hash_key

  item = templatefile("${path.module}/assets/period.json", {
    description = each.value.description,
    end_time    = each.value.end_time,
    months      = each.value.months,
    name        = each.value.name,
    period      = each.value.name,
    start_time  = each.value.start_time,
    weekdays    = each.value.weekdays,
  })
}

## Provision the schedules in the dynamodb table 
resource "aws_dynamodb_table_item" "schedules" {
  for_each = var.schedules

  table_name = data.aws_dynamodb_table.table.name
  hash_key   = data.aws_dynamodb_table.table.hash_key

  item = templatefile("${path.module}/assets/schedule.json", {
    description     = each.value.description,
    name            = each.value.name,
    override_status = each.value.override_status,
    periods         = each.value.periods,
    timezone        = each.value.timezone,
  })
}
