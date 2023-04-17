terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.36.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraform-remote-state" # TODO: replace with your state bucket
    region = "eu-north-1" # TODO: Update with your preferred region
    key    = "dfns-backup-bucket/terraform.tfstate"
  }
}
