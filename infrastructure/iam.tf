# -----------------------------------------------------------
# IAM Role — allows EC2 to assume this role
# EC2 uses this instead of hardcoded access keys
# -----------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------
# Attach CloudWatch policy to the role
# EC2 needs this to write logs and metrics to CloudWatch
# This is the ONLY permission EC2 gets — least privilege
# -----------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# -----------------------------------------------------------
# Instance Profile — wraps the role so EC2 can use it
# EC2 does not attach roles directly — it uses instance profiles
# -----------------------------------------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-profile"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
