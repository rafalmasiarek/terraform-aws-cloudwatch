## Usage

```hcl
module "nat_alarm" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git?ref=v0.1.0"

  type                = "metric-alarm"
  name                = "nat-a-error-port-allocation"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 15

  metrics = [{
    namespace   = "AWS/NATGateway"
    metric_name = "ErrorPortAllocation"
    dimensions  = { NatGatewayId = module.nat.nat_gateway_ids["a"] }
  }]
}
```

A composite alarm - boolean AND/OR/NOT over alarms already defined
elsewhere:

```hcl
module "nat_combined" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git?ref=v0.1.0"

  type       = "composite-alarm"
  name       = "nat-a-combined"
  alarm_rule = "ALARM(\"${module.nat_alarm.alarm_name}\") AND ALARM(\"${module.nat_packets_drop.alarm_name}\")"
}
```

Calling `modules/metric-alarm`, `modules/log-group`, or
`modules/composite-alarm` directly, instead of through this root
dispatcher, works identically - e.g.:

```hcl
module "nat_alarm" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=v0.1.0"

  name                = "nat-a-error-port-allocation"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 15
  metrics             = [{ namespace = "AWS/NATGateway", metric_name = "ErrorPortAllocation", dimensions = { NatGatewayId = "..." } }]
}
```

## Why a dispatcher at all

`var.type` exists purely as a convenience - one `source` works for any of
the three kinds, picked at the call site by a variable instead of by path.
It isn't a replacement for the direct submodule paths, and it doesn't add
any behavior the submodules don't already have on their own: it just
forwards every input straight through and re-exposes every submodule's
outputs (`null` for whichever one wasn't instantiated).

## Query mode

`modules/metric-alarm` and `modules/composite-alarm` (and this root
dispatcher, forwarding to either) also accept a `query` - a SQL-like
string parsed by
[terraform-provider-cwquery](https://github.com/rafalmasiarek/terraform-provider-cwquery),
as an alternative to setting the typed fields (`comparison_operator`/
`metrics`/`alarm_rule`) directly:

```hcl
module "nat_alarm" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git?ref=v0.1.0"

  type               = "metric-alarm"
  name               = "nat-a-error-port-allocation"
  evaluation_periods = 15

  query = <<-EOT
    SELECT ErrorPortAllocation FROM AWS/NATGateway
    WHERE NatGatewayId = '${module.nat.nat_gateway_ids["a"]}'
    HAVING value > 0
  EOT
}
```

This is an additional convenience, not a replacement - the typed fields
above remain the primary interface. See `terraform-provider-cwquery`'s
`docs/grammar-spec.md` for the full grammar (simple comparisons, metric
math, anomaly detection, and composite AND/OR/NOT expressions).

## Naming and uniqueness

Every submodule solves the same problem the same way: `alarm_name` and log
group names must each be unique per AWS account+region, and a bare
semantic string (e.g. `"a"`) carries no such guarantee across separate
deployments of whatever module calls this one. When `use_tagger = true`
(the default), the final name is built from
[terraform-null-tagger](https://github.com/rafalmasiarek/terraform-null-tagger)'s
`computed_name` - namespace/environment-aware, unique by construction. With
`use_tagger = false` there is no other uniqueness source available, and the
caller becomes responsible for keeping names unique across their whole
account/region.

`modules/log-group` additionally never lets a name start with `aws/` - that
prefix is reserved for AWS-managed log groups and is rejected by the
`CreateLogGroup` API; this module's own validation catches it at `terraform
plan` instead of at `apply`.

## What this family does not include (yet)

`log-group`, `metric-alarm`, and `composite-alarm` exist today - all three
have real, existing consumers. `metric-filter` (deriving a custom metric
from log content) and `metric-stream` (exporting metrics to S3/a third
party, beyond CloudWatch's own 15-month retention) are real,
well-established CloudWatch concepts too, but neither has a consumer in
this module family yet - added only when one does.
