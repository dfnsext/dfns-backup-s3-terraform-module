output "bucket_account_id" {
  value = var.aws_account_id
}

output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_region" {
  value = aws_s3_bucket.this.region
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_full_inventory_name" {
  value = local.bucket_full_inventory_name
}
