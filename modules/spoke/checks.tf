
check "organizations" {
  # Both enable_organizations and enable_standalone cannot be set to true 
  assert {
    condition     = !(var.enable_organizations == true && var.enable_standalone == true)
    error_message = "Both 'enable_organizations' and 'enable_standalone' cannot be set to true"
  }

  # Is organizations is enabled we need organizations units to be set 
  assert {
    condition     = !(var.enable_organizations == true && length(var.organizational_units) > 0)
    error_message = "When 'enable_organizations' is set to true, 'organizational_units' must be set"
  }

  # If standalone is enabled we dont need any organizations units 
  assert {
    condition     = !(var.enable_standalone == true && length(var.organizational_units) == 0)
    error_message = "When 'enable_standalone' is set to true, 'organizational_units' must not be set"
  }
}
