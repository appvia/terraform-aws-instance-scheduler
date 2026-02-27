mock_provider "aws" {}

run "spoke_shared_bucket_outputs" {
  command = plan

  module {
    source = "./modules/spoke"
  }

  variables {
    cloudformation_bucket_url   = "https://shared-scheduler-templates.s3.eu-west-2.amazonaws.com/cloudformation/instance-scheduler-on-aws-remote.template"
    enable_cloudformation_macro = false
    scheduler_account_id        = "123456789012"
  }
}

run "spokes_shared_bucket_outputs" {
  command = plan

  module {
    source = "./modules/spokes"
  }

  variables {
    cloudformation_bucket_url   = "https://shared-scheduler-templates.s3.eu-west-2.amazonaws.com/cloudformation/instance-scheduler-on-aws-remote.template"
    enable_cloudformation_macro = false
    scheduler_account_id        = "123456789012"
    tags                        = {}
  }
}
