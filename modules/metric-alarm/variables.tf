variable "name" {
  description = "Semantic alarm name, including whatever resource-type infix the caller needs for clarity (e.g. \"nat-a-error-port-allocation\") - made globally unique via the tagger when use_tagger = true (alarm_name must be unique per account+region, and this string alone is not)."
  type        = string
}

variable "alarm_description" {
  type    = string
  default = null
}

variable "query" {
  description = "A cwquery string (see terraform-provider-cwquery) - an alternative to setting comparison_operator/metrics directly. Exactly one of query or (comparison_operator + metrics) must be set."
  type        = string
  default     = null

  validation {
    condition     = (var.query != null) != (var.comparison_operator != null && var.metrics != null)
    error_message = "Exactly one of `query` or both `comparison_operator` and `metrics` must be set - these are two alternative, mutually exclusive ways to define the alarm's condition."
  }
}

variable "comparison_operator" {
  description = "\"GreaterThanThreshold\" | \"GreaterThanOrEqualToThreshold\" | \"LessThanThreshold\" | \"LessThanOrEqualToThreshold\" | \"LessThanLowerOrGreaterThanUpperThreshold\" | \"LessThanLowerThreshold\" | \"GreaterThanUpperThreshold\". Not used when query is set."
  type        = string
  default     = null
}

variable "threshold" {
  description = "Not used when query is set, or when using threshold_metric_id directly."
  type        = number
  default     = null

  validation {
    condition     = var.query != null || ((var.threshold != null) != (var.threshold_metric_id != null))
    error_message = "In direct mode (no query), exactly one of threshold or threshold_metric_id must be set - CloudWatch alarms use one or the other, never both."
  }
}

variable "threshold_metric_id" {
  description = "id of a metrics entry whose expression is ANOMALY_DETECTION_BAND(...) - used instead of threshold for anomaly-detection alarms. Not used when query is set (an anomaly-detection query already resolves this itself)."
  type        = string
  default     = null
}

variable "evaluation_periods" {
  type = number
}

variable "datapoints_to_alarm" {
  description = "Defaults to evaluation_periods (every period must breach) when unset."
  type        = number
  default     = null
}

variable "treat_missing_data" {
  type    = string
  default = "missing"
}

variable "period_seconds" {
  description = "Shared across every entry in metrics - CloudWatch alarms evaluate all their metrics over the same period."
  type        = number
  default     = 300
}

variable "actions_enabled" {
  description = "Native aws_cloudwatch_metric_alarm field - set false to temporarily suspend action-triggering without deleting the alarm."
  type        = bool
  default     = true
}

variable "metrics" {
  description = <<-EOT
    One or more metrics. A single entry with no `expression` is used directly as a
    plain metric_name/namespace alarm - no metric_query involved. Two or more entries,
    or any entry with `expression` set, produce one metric_query block per entry
    (expression entries combine the others by their `id`).
  EOT
  type = list(object({
    id          = optional(string) # required when metrics has >1 entry, or referenced by another entry's expression
    namespace   = optional(string) # required unless this entry is itself an expression
    metric_name = optional(string) # required unless this entry is itself an expression
    stat        = optional(string, "Sum")
    unit        = optional(string)
    dimensions  = optional(map(string), {})
    expression  = optional(string) # set instead of namespace/metric_name - combines other entries' ids
    return_data = optional(bool)   # default: true for a lone entry or an expression entry, false otherwise
  }))
  default = null

  validation {
    condition     = var.metrics == null || length(var.metrics) > 0
    error_message = "metrics must have at least one entry."
  }
  validation {
    condition     = var.metrics == null || length(var.metrics) == 1 || alltrue([for m in var.metrics : m.id != null])
    error_message = "Every entry needs its own id once metrics has more than one entry."
  }
  validation {
    condition     = var.metrics == null || alltrue([for m in var.metrics : (m.expression != null) != (m.namespace != null && m.metric_name != null)])
    error_message = "Every entry needs exactly one of: expression, or both namespace and metric_name."
  }
}

variable "alarm_actions" {
  type    = list(string)
  default = []
}

variable "ok_actions" {
  type    = list(string)
  default = []
}

variable "insufficient_data_actions" {
  type    = list(string)
  default = []
}
