output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance — use this to SSH and view Nginx"
  value       = aws_instance.app_server.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.alerts.arn
}

output "nginx_url" {
  description = "URL to view Nginx page in your browser"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "ssh_command" {
  description = "Command to SSH into your EC2 instance"
  value       = "ssh -i ~/.ssh/aws-infra-key ubuntu@${aws_instance.app_server.public_ip}"
}
