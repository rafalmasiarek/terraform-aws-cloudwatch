module "log_group" {
  count  = var.type == "log-group" ? 1 : 0
  source = "./modules/log-group"

  service           = var.service
  name              = var.name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  log_group_class   = var.log_group_class
  skip_destroy      = var.skip_destroy

  use_tagger     = var.use_tagger
  tagger_context = var.tagger_context
  tags           = var.tags
}

module "metric_alarm" {
  count  = var.type == "metric-alarm" ? 1 : 0
  source = "./modules/metric-alarm"

  name                      = var.name
  alarm_description         = var.alarm_description
  query                     = var.query
  comparison_operator       = var.comparison_operator
  threshold                 = var.threshold
  threshold_metric_id       = var.threshold_metric_id
  evaluation_periods        = var.evaluation_periods
  datapoints_to_alarm       = var.datapoints_to_alarm
  treat_missing_data        = var.treat_missing_data
  period_seconds            = var.period_seconds
  actions_enabled           = var.actions_enabled
  metrics                   = var.metrics
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  use_tagger     = var.use_tagger
  tagger_context = var.tagger_context
  tags           = var.tags
}

module "composite_alarm" {
  count  = var.type == "composite-alarm" ? 1 : 0
  source = "./modules/composite-alarm"

  name                      = var.name
  alarm_description         = var.alarm_description
  query                     = var.query
  alarm_rule                = var.alarm_rule
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  use_tagger     = var.use_tagger
  tagger_context = var.tagger_context
  tags           = var.tags
}
