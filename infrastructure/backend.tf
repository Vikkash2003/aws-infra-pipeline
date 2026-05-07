terraform {
  backend "s3" {
    bucket         = "aws-infra-pipeline-tfstate-1e1a001b"
    key            = "infrastructure/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "aws-infra-pipeline-tfstate-locks"
    encrypt        = true
  }
}
