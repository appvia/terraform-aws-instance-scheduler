
locals {
  ## The account id of the scheduler account 
  account_id = data.aws_caller_identity.current.account_id

  ## A map of the resources which are going to be tagged - we could 
  ## probably reduce this somewhat
  resources_in_scope_all = merge({
    "aurora" : var.enable_aurora ? {
      "tag_name" : var.scheduled_tag_name,
      "tag_value" : var.scheduled_tag_value,
      "schedule" : var.aurora.schedule ? var.aurora.schedule : var.schedule,
      "excluded_tags" : var.aurora.excluded_tags
      "execution_policy" : jsonencode({
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

    "autoscaling" : var.enable_autoscaling ? {
      "tag_name" : var.autoscaling.scheduled_tag_name ? var.autoscaling.scheduled_tag_name : var.scheduled_tag_name,
      "tag_value" : var.autoscaling.scheduled_tag_value ? var.autoscaling.scheduled_tag_value : var.scheduled_tag_value,
      "schedule" : var.autoscaling.schedule ? var.autoscaling.schedule : var.schedule
      "excluded_tags" : var.autoscaling.excluded_tags
      "execution_policy" : jsonencode({
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

    "ec2" : var.enable_ec2 ? {
      "tag_name" : var.scheduled_tag_name,
      "tag_value" : var.scheduled_tag_value
      "schedule" : var.ec2.schedule ? var.ec2.schedule : var.schedule,
      "excluded_tags" : var.ec2.excluded_tags
      "execution_policy" : jsonencode({
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

    "rds" : var.enable_rds ? {
      "tag_name" : var.scheduled_tag_name,
      "tag_value" : var.scheduled_tag_value,
      "schedule" : var.rds.schedule ? var.rds.schedule : var.schedule,
      "excluded_tags" : var.rds.excluded_tags
      "execution_policy" : jsonencode({
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

    "documentdb" : var.enable_documentdb ? {
      "tag_name" : var.scheduled_tag_name,
      "tag_value" : var.scheduled_tag_value,
      "schedule" : var.documentdb.schedule ? var.documentdb.schedule : var.schedule,
      "excluded_tags" : var.documentdb.excluded_tags
      "execution_policy" : jsonencode({
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

    "neptune" : var.enable_neptune ? {
      "tag_name" : var.scheduled_tag_name,
      "tag_value" : var.scheduled_tag_value,
      "schedule" : var.neptune.schedule ? var.neptune.schedule : var.schedule,
      "excluded_tags" : var.neptune.excluded_tagsA
      "execution_policy" : jsonencode({
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
