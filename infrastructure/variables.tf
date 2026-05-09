variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used as prefix for all resource names"
  type        = string
  default     = "aws-infra-pipeline"
}

variable "environment" {
  description = "Deployment environment name — dev, staging, or prod"
  type        = string
  default     = "dev"
}

variable "ec2_instance_type" {
  description = "EC2 instance type — t3.micro is free tier eligible"
  type        = string
  default     = "t3.micro"
}

variable "ec2_public_key" {
  description = "Optional public key contents for EC2 SSH access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "my_ip" {
  description = "Your public IP address with /32 suffix for SSH access. Find it at checkip.amazonaws.com"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}
