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

locals {
  output = {
    bucket_name                = aws_s3_bucket.this.id
    bucket_region              = aws_s3_bucket.this.region
    bucket_arn                 = aws_s3_bucket.this.arn
    bucket_full_inventory_name = local.bucket_full_inventory_name
  }
}

module "config" {
  source  = "spacelift.io/dfnsco/aws-shared-configuration/aws"
  version = "0.2.0"

  backend_type = "aws-sm"
  action       = "store"
  environment  = var.environment
  region       = var.aws_region
  store_module = "aws-ecs-infra"
  store_values = jsonencode(local.output)

  # Shared configuration is always stored in the primary AWS regin
  providers = {
    aws = aws.primary
  }
}
