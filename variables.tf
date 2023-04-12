variable "aws_account_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_region" {
  type = string
}

variable "object_lock_retention_days" {
  type = number
}

variable "backup_job_role_arn" {
  type = string
}

variable "additional_roles_with_bucket_access" {
  type        = list(string)
  default     = []
  description = "Additional roles that will have access to S3 bucket. This is useful for testing/dev, to allow other roles to deploy/change infra easily, and not be locked-out after first deployement."
}
