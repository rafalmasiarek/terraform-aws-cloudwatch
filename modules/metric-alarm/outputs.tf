output "alarm_arn" {
  value = aws_cloudwatch_metric_alarm.this.arn
}

output "alarm_name" {
  description = "The final, tagger-made-unique name actually given to the alarm - not necessarily var.name as-is."
  value       = aws_cloudwatch_metric_alarm.this.alarm_name
}
