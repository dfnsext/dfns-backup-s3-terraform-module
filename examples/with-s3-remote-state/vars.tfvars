aws_account_id                      = "YOUR_AWS_ACCOUNT_ID"
aws_region                          = "YOUR_AWS_REGION"
bucket_name                         = "YOUR_BACKUP_BUCKET_NAME"
bucket_region                       = "YOUR_BACKUP_BUCKET_REGION" # has to be the same as aws_region
object_lock_retention_days          = 3650                        # 10 years
backup_job_role_arn                 = "DFNS_BACKUP_JOB_ROLE_ARN"  # provided by Dfns
additional_roles_with_bucket_access = []
