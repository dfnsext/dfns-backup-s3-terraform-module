
variable "aws_account_id" {
  type        = string
  description = "AWS account where you want the bucket deployed."
}

variable "aws_region" {
  type        = string
  description = "AWS Region where you want the bucket deployed."
}

variable "bucket_name" {
  type        = string
  description = "Name of the backup bucket."
}

variable "object_lock_retention_days" {
  type        = number
  description = "Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely. Set this to a high number (eg 100 years)."
}

variable "backup_job_role_arn" {
  type        = string
  description = "ARN of the Dfns backup job role that will perform the backups to this bucket."
}

variable "additional_roles_with_bucket_access" {
  type        = list(string)
  default     = []
  description = "Additional roles that will have access to S3 bucket. This is useful for testing/dev, to allow other roles to deploy/change infra easily, and not be locked-out after first deployement."
}
