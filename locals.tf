
locals {
  ## Is the current account id 
  account_id = data.aws_caller_identity.current.account_id

  ## Parameters for the cloudformation stack in the hub account 
  cloudformation_hub_stack_parameters = {
    AsgRulePrefix               = var.instance_scheduler_asg_rule_prefix
    AsgScheduledTagKey          = var.instance_scheduler_asg_tag_key
    CreateRdsSnapshot           = var.enable_rds_snapshot ? "yes" : "no"
    DefaultTimezone             = var.instance_scheduler_timezone
    EnableRdsClusterScheduling  = var.enable_rds_cluster_scheduler ? "yes" : "no"
    EnableSSMMaintenanceWindows = var.enable_ssm_maintenance_windows ? "yes" : "no"
    KmsKeyArns                  = join(",", var.kms_key_arns)
    LogRetentionDays            = var.instance_scheduler_log_group_retention
    OpsMonitoring               = var.enable_cloudwatch_dashboard ? "yes" : "no"
    Principals                  = join(",", var.instance_scheduler_principals)
    Regions                     = join(",", var.instance_scheduler_regions)
    ScheduleASGs                = var.enable_asg_scheduler ? "yes" : "no"
    ScheduleDocDb               = var.enable_docdb_scheduler ? "yes" : "no"
    ScheduleEC2                 = var.enable_ec2_scheduler ? "yes" : "no"
    ScheduleLambdaAccount       = var.enable_hub_account_scheduler ? "yes" : "no"
    ScheduleNeptune             = var.enable_neptune_scheduler ? "yes" : "no"
    ScheduleRds                 = var.enable_rds_scheduler ? "yes" : "no"
    SchedulerFrequency          = var.instance_scheduler_frequency
    SchedulingActive            = var.enable_scheduler ? "yes" : "no"
    StartedTags                 = var.instance_scheduler_start_tags
    StoppedTags                 = var.instance_scheduler_stop_tags
    TagName                     = var.instance_scheduler_tag_name
    Trace                       = var.enable_cloudwatch_debug_logging ? "yes" : "no"
    UsingAWSOrganizations       = var.enable_organizations
  }
}
