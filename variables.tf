variable "type" {
  description = "Which submodule to instantiate: \"log-group\", \"metric-alarm\", or \"composite-alarm\". Calling modules/log-group, modules/metric-alarm, or modules/composite-alarm directly still works too - this is a convenience dispatcher, not a replacement."
  type        = string

  validation {
    condition     = contains(["log-group", "metric-alarm", "composite-alarm"], var.type)
    error_message = "type must be \"log-group\", \"metric-alarm\", or \"composite-alarm\"."
  }

  # Terraform has no conditionally-required variable, so each type's own
  # required subset is enforced here instead, cross-referencing the other
  # variables below (supported since Terraform 1.9).
  validation {
    condition     = var.type != "log-group" || (var.service != null && var.retention_in_days != null)
    error_message = "type = \"log-group\" requires service and retention_in_days."
  }
  validation {
    condition     = var.type != "metric-alarm" || (var.evaluation_periods != null && (var.query != null || (var.comparison_operator != null && var.metrics != null)))
    error_message = "type = \"metric-alarm\" requires evaluation_periods, and either query or both comparison_operator and metrics."
  }
  validation {
    condition     = var.type != "composite-alarm" || (var.query != null || var.alarm_rule != null)
    error_message = "type = \"composite-alarm\" requires either query or alarm_rule."
  }
}

# --- modules/log-group passthrough (only relevant when type = "log-group") ---

variable "service" {
  type    = string
  default = null

  validation {
    condition     = var.service == null || can(regex("^[a-zA-Z0-9_.-]+$", var.service))
    error_message = "service must only contain a-z, A-Z, 0-9, '_', '-', '.'."
  }
}

variable "retention_in_days" {
  type    = number
  default = null
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "log_group_class" {
  type    = string
  default = null
}

variable "skip_destroy" {
  type    = bool
  default = false
}

# --- modules/metric-alarm passthrough (only relevant when type = "metric-alarm") ---
# --- modules/composite-alarm passthrough (only relevant when type = "composite-alarm") ---

variable "alarm_description" {
  type    = string
  default = null
}

# query/alarm_rule are shared across metric-alarm (query only) and
# composite-alarm (query or alarm_rule) - a single root variable each,
# passed through to whichever submodule is active, same as name/use_tagger.

variable "query" {
  type    = string
  default = null
}

variable "alarm_rule" {
  type    = string
  default = null
}

variable "comparison_operator" {
  type    = string
  default = null
}

variable "threshold" {
  type    = number
  default = null
}

variable "threshold_metric_id" {
  type    = string
  default = null
}

variable "evaluation_periods" {
  type    = number
  default = null
}

variable "datapoints_to_alarm" {
  type    = number
  default = null
}

variable "treat_missing_data" {
  type    = string
  default = "missing"
}

variable "period_seconds" {
  type    = number
  default = 300
}

variable "actions_enabled" {
  type    = bool
  default = true
}

variable "metrics" {
  type = list(object({
    id          = optional(string)
    namespace   = optional(string)
    metric_name = optional(string)
    stat        = optional(string, "Sum")
    unit        = optional(string)
    dimensions  = optional(map(string), {})
    expression  = optional(string)
    return_data = optional(bool)
  }))
  default = null
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

# --- shared by both ---

variable "name" {
  description = "Semantic resource name - see modules/log-group or modules/metric-alarm for exactly how it's used."
  type        = string
}

# Plain passthrough to whichever submodule gets instantiated - the root
# itself creates nothing and has no taggable resource of its own, so it
# doesn't carry a full tagger.tf (data "tagger_origin" would describe this
# dispatcher, not the actual resource either submodule creates).

variable "use_tagger" {
  type    = bool
  default = true
}

variable "tagger_context" {
  type    = any
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
