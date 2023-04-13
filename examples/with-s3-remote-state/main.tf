module "my_custom_dfns_backup" {
  source = "github.com/dfnsext/dfns-backup-s3-terraform-module?ref=v1.0.1"

  aws_account_id                      = var.aws_account_id
  bucket_name                         = var.bucket_name
  bucket_region                       = var.aws__region
  object_lock_retention_days          = var.object_lock_retention_days
  backup_job_role_arn                 = var.backup_job_role_arn
  additional_roles_with_bucket_access = var.additional_roles_with_bucket_access
}
