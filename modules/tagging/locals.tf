
locals {
  ## A map of the resources which are going to be tagged 
  resources_in_scope_all = {
    for k, v in local.all_resources : k => v if v != null
  }

  ## A map of the resources which are going to be tagged - we could 
  ## probably reduce this somewhat
  all_resources = merge({
    aurora = var.enable_aurora ? {
      tag_name      = coalesce(var.scheduler_tag_name, var.scheduler_tag_value)
      tag_value     = coalesce(var.scheduler_tag_value, var.scheduler_tag_value)
      schedule      = coalesce(var.aurora.schedule, var.schedule)
      excluded_tags = coalesce(var.aurora.excluded_tags, [])
      execution_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "AuroraClusterTagging",
            "Effect" : "Allow",
            "Action" : [
              "rds:DescribeDBClusters",
              "rds:ListTagsForResource",
              "rds:AddTagsToResource"
            ],
            "Resource" : "*"
          }
        ]
      })
    } : null,

    autoscaling = var.enable_autoscaling ? {
      tag_name      = coalesce(var.autoscaling.scheduler_tag_name, var.scheduler_tag_name)
      tag_value     = coalesce(var.autoscaling.scheduler_tag_value, var.scheduler_tag_value)
      schedule      = coalesce(var.autoscaling.schedule, var.schedule)
      excluded_tags = coalesce(var.autoscaling.excluded_tags, [])
      execution_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "ASGInstanceTagging",
            "Effect" : "Allow",
            "Action" : [
              "autoscaling:DescribeAutoScalingGroups",
              "autoscaling:DescribeTags",
              "autoscaling:CreateOrUpdateTags"
            ],
            "Resource" : "*"
          }
        ]
      })
    } : null,

    ec2 = var.enable_ec2 == true ? {
      tag_name      = coalesce(var.scheduler_tag_name, var.scheduler_tag_name)
      tag_value     = coalesce(var.scheduler_tag_value, var.scheduler_tag_value)
      schedule      = coalesce(var.ec2.schedule, var.schedule)
      excluded_tags = coalesce(var.ec2.excluded_tags, [])
      execution_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "EC2InstanceTagging",
            "Effect" : "Allow",
            "Action" : [
              "ec2:DescribeInstances",
              "ec2:CreateTags"
            ],
            "Resource" : "*"
          }
        ]
      })
    } : null,

    rds = var.enable_rds ? {
      tag_name      = coalesce(var.scheduler_tag_name, var.scheduler_tag_value)
      tag_value     = coalesce(var.scheduler_tag_value, var.scheduler_tag_value)
      schedule      = coalesce(var.rds.schedule, var.schedule)
      excluded_tags = coalesce(var.rds.excluded_tags, [])
      execution_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "RDSInstanceTagging",
            "Effect" : "Allow",
            "Action" : [
              "rds:DescribeDBInstances",
              "rds:ListTagsForResource",
              "rds:AddTagsToResource"
            ],
            "Resource" : "*"
          }
        ]
      })
    } : null,

    documentdb = var.enable_documentdb ? {
      tag_name      = coalesce(var.scheduler_tag_name, var.scheduler_tag_value)
      tag_value     = coalesce(var.scheduler_tag_value, var.scheduler_tag_value)
      schedule      = coalesce(var.documentdb.schedule, var.schedule)
      excluded_tags = coalesce(var.documentdb.excluded_tags, [])
      execution_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "DocumentDBClusterTagging",
            "Effect" : "Allow",
            "Action" : [
              "documentdb:DescribeDBClusters",
              "documentdb:ListTagsForResource",
              "documentdb:AddTagsToResource"
            ],
            "Resource" : "*"
          }
        ]
      })
    } : null,

    neptune = var.enable_neptune ? {
      tag_name      = coalesce(var.scheduler_tag_name, var.scheduler_tag_value)
      tag_value     = coalesce(var.scheduler_tag_value, var.scheduler_tag_value)
      schedule      = coalesce(var.neptune.schedule, var.schedule)
      excluded_tags = coalesce(var.neptune.excluded_tags, [])
      execution_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "NeptuneClusterTagging",
            "Effect" : "Allow",
            "Action" : [
              "neptune-db:DescribeDBClusters",
              "neptune-db:ListTagsForResource",
              "neptune-db:AddTagsToResource"
            ],
            "Resource" : "*"
          }
        ]
      })
    } : null
  })
}
