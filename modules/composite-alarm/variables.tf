variable "name" {
  description = "Semantic alarm name, including whatever resource-type infix the caller needs for clarity - made globally unique via the tagger when use_tagger = true (alarm_name must be unique per account+region, and this string alone is not)."
  type        = string
}

variable "alarm_description" {
  type    = string
  default = null
}

variable "query" {
  description = "A cwquery composite string (ALARM(...)/AND/OR/NOT - see terraform-provider-cwquery) - an alternative to setting alarm_rule directly. Exactly one of query or alarm_rule must be set."
  type        = string
  default     = null

  validation {
    condition     = (var.query != null) != (var.alarm_rule != null)
    error_message = "Exactly one of `query` or `alarm_rule` must be set - these are two alternative, mutually exclusive ways to define the composite condition."
  }
}

variable "alarm_rule" {
  description = "Direct AWS alarm_rule syntax (e.g. \"ALARM(\\\"x\\\") AND ALARM(\\\"y\\\")\"), bypassing cwquery entirely. Not used when query is set."
  type        = string
  default     = null
}

variable "actions_enabled" {
  description = "Native aws_cloudwatch_composite_alarm field - set false to temporarily suspend action-triggering without deleting the alarm."
  type        = bool
  default     = true
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
