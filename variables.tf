variable "aws_account_id" {
  type        = string
  description = "AWS Account id of the S3 bucket."
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket."
}

variable "bucket_region" {
  type        = string
  description = "Region of the S3 bucket."
}

variable "object_lock_retention_days" {
  type        = number
  description = "Object lock retention time in days."
}

variable "backup_job_role_arn" {
  type        = string
  description = "(Optional) IAM role arn of the role which will perform the backups."
  default     = null
}

variable "additional_roles_with_bucket_access" {
  type        = list(string)
  description = "Additional roles that will have access to S3 bucket. This is useful for testing/dev, to allow other roles to deploy/change infra easily, and not be locked-out after first deployment."
  default     = []
}
