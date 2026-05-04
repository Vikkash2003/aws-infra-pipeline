variable "aws_region" {
  description = "AWS region where the state backend resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project for which the state backend resources will be created"
  type        = string
  default     = "aws-infra-pipeline"

}
