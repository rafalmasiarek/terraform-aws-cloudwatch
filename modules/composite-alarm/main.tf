locals {
  taggable = {
    this = {
      name       = var.name
      service    = {}
      attributes = []
      created_at = null
      extra_tags = {}
    }
  }

  # alarm_name must be unique per account+region - see modules/metric-alarm's
  # identical reasoning for alarm_name.
  alarm_name = var.use_tagger ? module.tagger["this"].computed_name : var.name

  parsed = var.query != null ? provider::cwquery::parse(var.query) : null

  # coalesce() errors when every argument is null (which is exactly what
  # happens here if a SELECT-kind query is mistakenly fed in -
  # local.parsed.alarm_rule stays null for a "metric" kind result) - a
  # plain ternary tolerates that and lets the precondition below produce
  # the actual, readable error instead of a cryptic function-call failure.
  resolved_alarm_rule = var.alarm_rule != null ? var.alarm_rule : try(local.parsed.alarm_rule, null)
}

resource "aws_cloudwatch_composite_alarm" "this" {
  alarm_name        = local.alarm_name
  alarm_description = var.alarm_description
  alarm_rule        = local.resolved_alarm_rule
  actions_enabled   = var.actions_enabled

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = local.tagger_tags["this"]

  lifecycle {
    precondition {
      condition     = local.parsed == null || local.parsed.kind == "composite"
      error_message = "query must be a composite (ALARM/AND/OR/NOT) cwquery expression, not a SELECT query - use modules/metric-alarm for that."
    }
  }
}
