
locals {
  ## The account id of the scheduler account
  account_id = data.aws_caller_identity.current.account_id

  ## The current region
  region = data.aws_region.current.name

  ## The expected arn of the s3 bucket
  bucket_arn = format("arn:aws:s3:::%s", var.cloudformation_bucket_name)

  ## Parameters for the cloudformation stack in the hub account
  cloudformation_hub_stack_parameters = {
    AsgRulePrefix               = var.scheduler_asg_rule_prefix
    AsgScheduledTagKey          = var.scheduler_asg_tag_key
    CreateRdsSnapshot           = var.enable_rds_snapshot ? "Yes" : "No"
    DefaultTimezone             = var.scheduler_timezone
    EnableRdsClusterScheduling  = var.enable_rds_cluster_scheduler ? "Enabled" : "Disabled"
    EnableSSMMaintenanceWindows = var.enable_ssm_maintenance_windows ? "Yes" : "No"
    KmsKeyArns                  = join(",", var.kms_key_arns)
    LogRetentionDays            = var.scheduler_log_group_retention
    OpsMonitoring               = var.enable_cloudwatch_dashboard ? "Enabled" : "Disabled"
    Principals                  = join(",", var.scheduler_organizations_ids)
    Regions                     = join(",", var.scheduler_regions)
    ScheduleASGs                = var.enable_asg_scheduler ? "Enabled" : "Disabled"
    ScheduleDocDb               = var.enable_docdb_scheduler ? "Enabled" : "Disabled"
    ScheduleEC2                 = var.enable_ec2_scheduler ? "Enabled" : "Disabled"
    ScheduleLambdaAccount       = var.enable_hub_account_scheduler ? "Yes" : "No"
    ScheduleNeptune             = var.enable_neptune_scheduler ? "Enabled" : "Disabled"
    ScheduleRds                 = var.enable_rds_scheduler ? "Enabled" : "Disabled"
    SchedulerFrequency          = var.scheduler_frequency
    SchedulingActive            = var.enable_scheduler ? "Yes" : "No"
    StartedTags                 = var.scheduler_start_tags
    StoppedTags                 = var.scheduler_stop_tags
    TagName                     = var.scheduler_tag_name
    Trace                       = var.enable_debug ? "Yes" : "No"
    UsingAWSOrganizations       = var.enable_organizations ? "Yes" : "No"
  }
}
