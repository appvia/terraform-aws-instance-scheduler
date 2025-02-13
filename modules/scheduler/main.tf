
## Craft a resource iam policy for the bucket
data "aws_iam_policy_document" "bucket" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["${local.bucket_arn}/*", local.bucket_arn]

    principals {
      type        = "Service"
      identifiers = ["cloudformation.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = var.enable_organizational_bucket ? [] : toset([])

      content {
        test     = "StringEquals"
        variable = "aws:PrincipalOrgID"
        values   = var.organizational_id
      }
    }
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = [local.bucket_arn, "${local.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", local.account_id)]
    }

    dynamic "condition" {
      for_each = var.enable_organizational_bucket ? [] : toset([])

      content {
        test     = "StringNotEquals"
        variable = "aws:PrincipalOrgID"
        values   = var.organizational_id
      }
    }
  }
}

## Provision an s3 bucket to store the cloudformation templates
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  acl                                      = "private"
  attach_deny_incorrect_encryption_headers = true
  attach_deny_insecure_transport_policy    = true
  attach_deny_unencrypted_object_uploads   = true
  attach_require_latest_tls_policy         = true
  bucket                                   = var.cloudformation_bucket_name
  control_object_ownership                 = true
  force_destroy                            = true
  object_ownership                         = "ObjectWriter"
  policy                                   = data.aws_iam_policy_document.bucket.json
  tags                                     = var.tags

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id                                     = "remove-incomplete-uploads"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  versioning = {
    status     = true
    mfa_delete = false
  }
}

## Upload the cloudformation template to the bucket
resource "aws_s3_object" "instance_scheduler_template" {
  acl                    = "private"
  bucket                 = module.s3_bucket.s3_bucket_id
  key                    = "cloudformation/instance-scheduler-on-aws.template"
  server_side_encryption = "AES256"

  content = templatefile("${path.module}/assets/cloudformation/instance-scheduler-on-aws.template", {
    tags = var.tags
  })
}

## Upload the cloudformation template to the bucket
resource "aws_s3_object" "instance_scheduler_template_remote" {
  acl                    = "private"
  bucket                 = module.s3_bucket.s3_bucket_id
  key                    = "cloudformation/instance-scheduler-on-aws-remote.template"
  server_side_encryption = "AES256"

  content = templatefile("${path.module}/assets/cloudformation/instance-scheduler-on-aws-remote.template", {
    tags = var.tags
  })
}

## Provision the cloudformation stack within the centralized account
resource "aws_cloudformation_stack" "hub" {
  name         = var.cloudformation_hub_stack_name
  capabilities = var.cloudformation_hub_stack_capabilities
  parameters   = local.cloudformation_hub_stack_parameters
  template_url = format("https://%s.s3.amazonaws.com/%s", module.s3_bucket.s3_bucket_id, aws_s3_object.instance_scheduler_template.key)
  tags         = var.tags

  depends_on = [aws_s3_object.instance_scheduler_template]
}
