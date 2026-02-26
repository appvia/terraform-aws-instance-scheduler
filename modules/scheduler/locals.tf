
locals {
  ## The account id of the scheduler account
  account_id = data.aws_caller_identity.current.account_id
  ## The current region
  region = data.aws_region.current.region
  ## The expected arn of the s3 bucket
  bucket_arn = format("arn:aws:s3:::%s", var.cloudformation_bucket_name)

  ## Parameters for the cloudformation stack in the hub account
  cloudformation_hub_stack_parameters = {
    # Infrastructure
    Namespace             = "default"
    Principals            = join(",", var.scheduler_organizations_ids)
    RetainDataAndLogs     = var.enable_retain_logs ? "Enabled" : "Disabled"
    TagName               = var.scheduler_tag_name
    UsingAWSOrganizations = var.enable_organizations ? "Yes" : "No"

    # GlobalSettings
    AsgRulePrefix               = var.scheduler_asg_rule_prefix
    AsgScheduledTagKey          = var.scheduler_asg_tag_key
    CreateRdsSnapshot           = var.enable_rds_snapshot ? "Yes" : "No"
    DefaultTimezone             = var.scheduler_timezone
    EnableSSMMaintenanceWindows = var.enable_ssm_maintenance_windows ? "Yes" : "No"
    SchedulerFrequency          = var.scheduler_frequency
    SchedulingActive            = var.enable_scheduler ? "Yes" : "No"

    # Hub-Account Scheduling
    KmsKeyArns = join(",", var.kms_key_arns)
    Regions    = join(",", var.scheduler_regions)

    # Monitoring
    LogRetentionDays = var.scheduler_log_group_retention
    OpsMonitoring    = var.enable_cloudwatch_dashboard ? "Enabled" : "Disabled"
    Trace            = var.enable_debug ? "Yes" : "No"

    # Other
    MemorySize             = var.scheduler_memory_size
    OrchestratorMemorySize = var.scheduler_orchestrator_memory_size
  }
}
