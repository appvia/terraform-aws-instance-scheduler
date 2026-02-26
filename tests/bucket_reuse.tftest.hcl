mock_provider "aws" {}

run "spoke_shared_bucket_outputs" {
  command = plan

  module {
    source = "./modules/spoke"
  }

  variables {
    cloudformation_bucket_name  = "shared-scheduler-templates"
    enable_cloudformation_macro = false
    scheduler_account_id        = "123456789012"
  }

  assert {
    condition     = output.bucket_name == "shared-scheduler-templates"
    error_message = "spoke bucket_name output should mirror cloudformation_bucket_name input"
  }

  assert {
    condition     = output.bucket_arn == "arn:aws:s3:::shared-scheduler-templates"
    error_message = "spoke bucket_arn output should be derived from cloudformation_bucket_name input"
  }
}

run "spokes_shared_bucket_outputs" {
  command = plan

  module {
    source = "./modules/spokes"
  }

  variables {
    cloudformation_bucket_name  = "shared-scheduler-templates"
    enable_cloudformation_macro = false
    scheduler_account_id        = "123456789012"
    tags                        = {}
  }

  assert {
    condition     = output.bucket_name == "shared-scheduler-templates"
    error_message = "spokes bucket_name output should mirror cloudformation_bucket_name input"
  }

  assert {
    condition     = output.bucket_arn == "arn:aws:s3:::shared-scheduler-templates"
    error_message = "spokes bucket_arn output should be derived from cloudformation_bucket_name input"
  }
}
