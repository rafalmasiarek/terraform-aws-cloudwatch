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

  # Log group names must be unique per account+region - var.name alone
  # carries no such guarantee across separate deployments of whatever
  # module calls this one. module.tagger["this"].computed_name already is
  # (namespace/environment-aware). With use_tagger = false there is no
  # other uniqueness source available, so var.name is used as-is and the
  # caller becomes responsible for keeping it unique across their whole
  # account/region.
  unique_name = var.use_tagger ? module.tagger["this"].computed_name : var.name

  # service is a stable grouping segment, shared across every environment -
  # it never goes through the tagger, only the leaf name does.
  log_group_name = "/${var.service}/${local.unique_name}"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  log_group_class   = var.log_group_class
  skip_destroy      = var.skip_destroy

  tags = local.tagger_tags["this"]
}
