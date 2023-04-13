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

remote_state {
  backend = "s3"
  config = {
    bucket = "terraform-remote-state" # TODO: replace with your state bucket
    region = var.aws_region
    key    = "dfns-backup-bucket/terraform.tfstate"
  }
}
