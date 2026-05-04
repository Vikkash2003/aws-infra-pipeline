terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------
# S3 Bucket — stores your Terraform state file remotely
# -----------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-tfstate-${random_id.suffix.hex}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "${var.project_name}-tfstate"
    ManagedBy = "Terraform"
    Purpose   = "Terraform state storage"
  }
}

# Random suffix ensures the S3 bucket name is globally unique
resource "random_id" "suffix" {
  byte_length = 4
}

# Enable versioning — allows recovery if state file gets corrupted
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption — state files can contain sensitive information
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access — a public state bucket is a critical misconfiguration
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------
# DynamoDB Table — locks the state during terraform apply
# prevents two people applying at the same time
# -----------------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "${var.project_name}-tfstate-locks"
    ManagedBy = "Terraform"
    Purpose   = "Terraform state locking"
  }
}
