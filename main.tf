locals {
  bucket_full_inventory_name   = "full-inventory"
  inventory_destination_prefix = "inventory"
  backup_job_role              = var.backup_job_role_arn == null ? {} : regex("arn:aws:iam::(?P<account_id>\\d+):role/(?P<role_name>.+)", var.backup_job_role_arn)
  backup_job_assumed_role_arn  = var.backup_job_role_arn == null ? "" : "arn:aws:sts::${local.backup_job_role.account_id}:assumed-role/${local.backup_job_role.role_name}/*"
  backup_job_arns_to_allow     = var.backup_job_role_arn == null ? [] : [var.backup_job_role_arn, local.backup_job_assumed_role_arn]
}

data "aws_caller_identity" "current" {
  lifecycle {
    postcondition {
      condition     = self.account_id == var.aws_account_id
      error_message = "The AWS account used by provider (${self.account_id}) must be the same as the one configured in variable 'aws_account_id' (${var.aws_account_id})"
    }
  }
}

data "aws_region" "current" {
  lifecycle {
    postcondition {
      condition     = self.name == var.bucket_region
      error_message = "The AWS region used by provider (${self.name}) must be the same as the one configured in variable 'bucket_region' (${var.bucket_region})"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket              = var.bucket_name
  object_lock_enabled = true


  tags = {
    Name = var.bucket_name
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = var.object_lock_retention_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

######################################################################
# Bucket policy
######################################################################

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json

  // adding most resources here, that way they get created before a restrictive policy is applied to the bucket (preventing any additional bucket modification)
  depends_on = [
    aws_s3_bucket_inventory.full_inventory,
    aws_s3_bucket_object_lock_configuration.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_versioning.this,
  ]
}

data "aws_iam_policy_document" "this" {
  # Deny some actions to all except root.
  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteBucket",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersion",
      "s3:PutBucketPolicy",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    condition {
      variable = "aws:PrincipalArn"
      test     = "ArnNotLike"
      values = concat([
        "arn:aws:iam::${var.aws_account_id}:root",
      ], var.additional_roles_with_bucket_access)
    }
  }

  # Deny all s3 actions on bucket and objects, from all except root + backup role + S3 service (for inventory)
  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    condition {
      variable = "aws:PrincipalArn"
      test     = "ArnNotLike"
      values = concat(
        ["arn:aws:iam::${var.aws_account_id}:root"],
        local.backup_job_arns_to_allow,
        var.additional_roles_with_bucket_access
      )
    }
    condition {
      variable = "aws:PrincipalServiceName"
      test     = "StringNotEquals"
      values = [
        "s3.amazonaws.com"
      ]
    }
  }

  # Allow AWS to do the inventory
  statement {
    sid    = "InventoryPolicy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/${local.inventory_destination_prefix}/*"
    ]
    condition {
      variable = "aws:SourceArn"
      test     = "ArnLike"
      values   = [aws_s3_bucket.this.arn]
    }
    condition {
      variable = "aws:SourceAccount"
      test     = "StringEquals"
      values   = [var.aws_account_id]
    }
    condition {
      variable = "s3:x-amz-acl"
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
    }
  }
}

######################################################################
# Bucket Inventory
######################################################################

resource "aws_s3_bucket_inventory" "full_inventory" {
  bucket = aws_s3_bucket.this.id
  name   = local.bucket_full_inventory_name

  included_object_versions = "Current"
  enabled                  = true
  optional_fields          = ["Size", "LastModifiedDate"]

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.this.arn
      prefix     = local.inventory_destination_prefix
    }
  }
}
