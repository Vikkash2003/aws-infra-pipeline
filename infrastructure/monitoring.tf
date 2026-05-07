# -----------------------------------------------------------
# SNS Topic — notification channel
# CloudWatch alarm publishes here when it triggers
# -----------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Name        = "${var.project_name}-${var.environment}-alerts"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------
# SNS Email Subscription
# After apply check your email and confirm the subscription
# Alerts will NOT arrive until you click the confirmation link
# -----------------------------------------------------------
resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# -----------------------------------------------------------
# CloudWatch Alarm — CPU utilization
# Fires when EC2 CPU exceeds 80% for 2 consecutive periods
# -----------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-alarm"
  alarm_description   = "Alarm fires when EC2 CPU exceeds 80% for 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name        = "${var.project_name}-${var.environment}-cpu-alarm"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
