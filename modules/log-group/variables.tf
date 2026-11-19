variable "service" {
  description = "Grouping segment, e.g. \"vpc\", \"ecs\", \"nat\" - shared across environments/deployments, used for console grouping (renders as /service/... in the log-group tree). No environment/namespace info belongs here."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.service))
    error_message = "service must only contain a-z, A-Z, 0-9, '_', '-', '.' - it becomes a path segment, not the whole name."
  }
}

variable "name" {
  description = "Semantic resource name, e.g. \"myvpc-flow-log\" - made globally unique via the tagger when use_tagger = true (log group names must be unique per account+region, and this string alone is not)."
  type        = string

  validation {
    condition     = !startswith(var.name, "aws/")
    error_message = "Can't start with \"aws/\" - that prefix is reserved for AWS-managed log groups (CreateLogGroup API restriction)."
  }
  validation {
    condition     = can(regex("^[a-zA-Z0-9_/.#-]+$", var.name))
    error_message = "Only a-z, A-Z, 0-9, '_', '-', '/', '.', '#' allowed (CreateLogGroup naming rules)."
  }
}

variable "retention_in_days" {
  description = "Required, no default - CloudWatch's own default is \"never expire\", which should never be a silent, implicit choice."
  type        = number
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "log_group_class" {
  description = "\"STANDARD\" (default) or \"INFREQUENT_ACCESS\" (cheaper storage for logs rarely queried - no Live Tail, slower Insights queries)."
  type        = string
  default     = null
}

variable "skip_destroy" {
  type    = bool
  default = false
}
