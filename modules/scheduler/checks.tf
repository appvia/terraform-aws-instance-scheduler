
check "organizational_bucket" {
  assert {
    condition     = !(var.enable_organizational_bucket == true && var.organizational_id == "")
    error_message = "If 'enable_organizational_bucket' is true, 'organizational_id' must be specified"
  }
}
