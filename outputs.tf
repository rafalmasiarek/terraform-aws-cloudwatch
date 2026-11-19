output "log_group_name" {
  value = try(module.log_group[0].log_group_name, null)
}

output "log_group_arn" {
  value = try(module.log_group[0].log_group_arn, null)
}

output "alarm_arn" {
  value = try(module.metric_alarm[0].alarm_arn, module.composite_alarm[0].alarm_arn, null)
}

output "alarm_name" {
  value = try(module.metric_alarm[0].alarm_name, module.composite_alarm[0].alarm_name, null)
}
