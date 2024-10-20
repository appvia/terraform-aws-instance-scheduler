
locals {
  ## The account id of the scheduler account 
  account_id = data.aws_caller_identity.current.account_id

  ## A mpa of the resources which are going to be tagged 
  resources_in_scope_all = merge({
    "autoscaling_groups" : var.autoscaling_groups.enable ? {
      "tag_name" : var.autoscaling_groups.scheduled_tag_name ? var.autoscaling_groups.scheduled_tag_name : var.scheduled_tag_name,
      "tag_value" : var.autoscaling_groups.scheduled_tag_value ? var.autoscaling_groups.scheduled_tag_value : var.scheduled_tag_value,
      "schedule" : var.autoscaling_groups.schedule ? var.autoscaling_groups.schedule : var.schedule
      "excluded_tags" : var.autoscaling_groups.excluded_tags
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

    "ec2" : var.ec2_instances.enable ? {
      "tag_name" : var.scheduled_tag_name,
      "tag_value" : var.scheduled_tag_value
      "schedule" : var.ec2_instances.schedule ? var.ec2_instances.schedule : var.schedule,
      "excluded_tags" : var.ec2_instances.excluded_tags
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

    "rds" : var.rds.enable ? {
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

    "rds_clusters" : var.rds_clusters.enable ? {
      "tag_name" : var.scheduled_tag_name,
      "tag_value" : var.scheduled_tag_value,
      "schedule" : var.rds_clusters.schedule ? var.rds_clusters.schedule : var.schedule,
      "excluded_tags" : var.rds_clusters.excluded_tags
      "execution_policy" : jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "RDSClusterTagging",
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

    "neptune" : var.neptune.enable ? {
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
