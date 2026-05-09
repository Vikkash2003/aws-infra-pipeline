# -----------------------------------------------------------
# SSH Key Pair
# Uploads your public key to AWS so you can SSH into EC2
# -----------------------------------------------------------
resource "aws_key_pair" "ec2_key" {
  count      = var.ec2_public_key == "" ? 0 : 1
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = var.ec2_public_key

  tags = {
    Name        = "${var.project_name}-${var.environment}-key"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------
# Data Source — Latest Ubuntu 22.04 AMI
# Never hardcode AMI IDs — they are region specific
# and change when Amazon releases updates
# -----------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical — the company that makes Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------
# EC2 Instance
# Your application server — t2.micro is free tier eligible
# -----------------------------------------------------------
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_public_key == "" ? null : aws_key_pair.ec2_key[0].key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Public IP — needed to access Nginx and SSH in Layer 1
  # In a real production system EC2 would be in a private subnet
  associate_public_ip_address = true

  # User data — runs when EC2 first boots
  # Installs and starts Nginx automatically
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>AWS Infrastructure Pipeline — ${var.environment}</h1>" > /var/www/html/index.html
  EOF

  # Root volume — 8GB gp3, encrypted
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-server"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
