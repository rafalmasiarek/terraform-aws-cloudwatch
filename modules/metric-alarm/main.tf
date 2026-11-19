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

  # alarm_name must be unique per account+region - var.name alone carries no
  # such guarantee across separate deployments of whatever module calls
  # this one. module.tagger["this"].computed_name already is
  # (namespace/environment-aware). With use_tagger = false there is no
  # other uniqueness source available, so var.name is used as-is and the
  # caller becomes responsible for keeping it unique across their whole
  # account/region.
  alarm_name = var.use_tagger ? module.tagger["this"].computed_name : var.name

  # query is an alternative to comparison_operator/threshold/metrics,
  # resolved via terraform-provider-cwquery - see variables.tf's
  # mutual-exclusivity validations. Whichever mode is active, exactly one
  # of effective_threshold/effective_threshold_metric_id ends up set: in
  # direct mode that's enforced by variable validation, in query mode it's
  # guaranteed by cwquery's own Compile() step.
  parsed = var.query != null ? provider::cwquery::parse(var.query) : null

  effective_comparison_operator = var.comparison_operator != null ? var.comparison_operator : try(local.parsed.comparison_operator, null)
  effective_threshold           = var.threshold != null ? var.threshold : try(local.parsed.threshold, null)
  # coalesce() errors when every argument is null (the common case here -
  # most alarms use threshold, not threshold_metric_id) - a plain ternary
  # tolerates that instead of requiring a non-null fallback.
  effective_threshold_metric_id = var.threshold_metric_id != null ? var.threshold_metric_id : try(local.parsed.threshold_metric_id, null)
  effective_metrics             = var.metrics != null ? var.metrics : try(local.parsed.metrics, null)

  # Basic stats are the only values CloudWatch's legacy top-level
  # `statistic` attribute accepts - a percentile (e.g. "p99") requires the
  # metric_query.metric.stat path instead, even for a single-entry alarm.
  basic_stats = ["SampleCount", "Average", "Sum", "Minimum", "Maximum"]

  # A lone entry with no expression and a basic stat is a plain
  # metric_name/namespace alarm - no metric_query involved at all.
  # Anything else (>1 entry, an expression, a percentile stat, or
  # effective_metrics being null because `query` resolved to a composite
  # kind - caught by the resource's lifecycle.precondition below) goes
  # through metric_query. && does not short-circuit in Terraform, so
  # effective_metrics == null would otherwise crash this expression
  # outright instead of reaching that precondition - try() avoids that.
  is_simple = try(
    length(local.effective_metrics) == 1 && local.effective_metrics[0].expression == null && contains(local.basic_stats, local.effective_metrics[0].stat),
    false
  )

  simple_metric = local.is_simple ? local.effective_metrics[0] : null

  metric_queries = local.is_simple ? [] : try([
    for m in local.effective_metrics : merge(m, {
      return_data = coalesce(m.return_data, m.expression != null)
    })
  ], [])
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = local.alarm_name
  alarm_description   = var.alarm_description
  comparison_operator = local.effective_comparison_operator
  threshold           = local.effective_threshold_metric_id != null ? null : local.effective_threshold
  threshold_metric_id = local.effective_threshold_metric_id
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = coalesce(var.datapoints_to_alarm, var.evaluation_periods)
  treat_missing_data  = var.treat_missing_data
  actions_enabled     = var.actions_enabled

  # Simple case: plain top-level metric fields, no metric_query at all.
  metric_name = local.is_simple ? local.simple_metric.metric_name : null
  namespace   = local.is_simple ? local.simple_metric.namespace : null
  period      = local.is_simple ? var.period_seconds : null
  statistic   = local.is_simple ? local.simple_metric.stat : null
  unit        = local.is_simple ? local.simple_metric.unit : null
  dimensions  = local.is_simple ? local.simple_metric.dimensions : null

  lifecycle {
    precondition {
      condition     = local.parsed == null || local.parsed.kind == "metric"
      error_message = "query must be a metric query (SELECT ...), not a composite (ALARM/AND/OR/NOT) expression - use modules/composite-alarm for that."
    }
  }

  dynamic "metric_query" {
    for_each = { for m in local.metric_queries : m.id => m }
    content {
      id          = metric_query.value.id
      expression  = metric_query.value.expression
      label       = metric_query.value.expression != null ? null : metric_query.value.metric_name
      return_data = metric_query.value.return_data

      dynamic "metric" {
        for_each = metric_query.value.expression == null ? [metric_query.value] : []
        content {
          namespace   = metric.value.namespace
          metric_name = metric.value.metric_name
          period      = var.period_seconds
          stat        = metric.value.stat
          unit        = metric.value.unit
          dimensions  = metric.value.dimensions
        }
      }
    }
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = local.tagger_tags["this"]
}
