
## Craft a resource iam policy for the bucket
data "aws_iam_policy_document" "bucket" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["${local.bucket_arn}/*", local.bucket_arn]

    principals {
      type        = "Service"
      identifiers = ["cloudformation.amazonaws.com"]
    }
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = [local.bucket_arn, "${local.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", local.account_id)]
    }
  }
}

## Provision an s3 bucket to store the cloudformation templates
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  acl                                      = "private"
  attach_deny_incorrect_encryption_headers = true
  attach_deny_insecure_transport_policy    = true
  attach_deny_unencrypted_object_uploads   = true
  attach_require_latest_tls_policy         = true
  bucket                                   = local.bucket_name
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
    mfa_delete = false
    status     = true
  }
}

## Upload the cloudformation remote template to the bucket
resource "aws_s3_object" "spoke_template" {
  acl                    = "private"
  bucket                 = module.s3_bucket.s3_bucket_id
  key                    = "cloudformation/instance-scheduler-on-aws-remote.template"
  server_side_encryption = "AES256"
  tags                   = var.tags

  content = templatefile("${path.module}/assets/cloudformation/instance-scheduler-on-aws-remote.template", {
    enable_macro = var.enable_cloudformation_macro
    macro_name   = var.cloudformation_macro_name
  })
}

## Provision the cloudformation macro if required
module "cloudformation_macro" {
  count  = var.enable_cloudformation_macro ? 1 : 0
  source = "../macro"

  artifacts_dir                       = var.artifacts_dir
  name_prefix                         = "spoke-default-tags"
  cloudformation_transform_name       = var.cloudformation_macro_name
  cloudformation_transform_stack_name = var.cloudformation_transform_stack_name
  tags                                = var.tags
}

## Provision a standalone cloudformation stack within the spoke account
resource "aws_cloudformation_stack" "spoke" {
  name         = var.cloudformation_spoke_stack_name
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
  parameters   = local.cloudformation_spoke_stack_parameters
  tags         = var.tags
  template_url = format("https://%s.s3.amazonaws.com/%s", module.s3_bucket.s3_bucket_id, aws_s3_object.spoke_template.key)

  depends_on = [
    aws_s3_object.spoke_template,
    module.cloudformation_macro,
  ]
}

