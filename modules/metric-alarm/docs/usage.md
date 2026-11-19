## Usage

A plain metric alarm - one entry in `metrics`, no `expression`:

```hcl
module "nat_error_port_allocation" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=v0.1.0"

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

A metric-math alarm - several entries, combined by an `expression` entry
that references the others' `id`:

```hcl
module "nat_bandwidth_utilization" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=v0.1.0"

  name                = "nat-a-bandwidth-utilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  evaluation_periods  = 3

  metrics = [
    {
      id          = "bytes_out"
      namespace   = "AWS/NATGateway"
      metric_name = "BytesOutToDestination"
      dimensions  = { NatGatewayId = module.nat.nat_gateway_ids["a"] }
    },
    {
      id          = "bytes_in"
      namespace   = "AWS/NATGateway"
      metric_name = "BytesInFromDestination"
      dimensions  = { NatGatewayId = module.nat.nat_gateway_ids["a"] }
    },
    {
      id          = "utilization"
      expression  = "(bytes_out + bytes_in) * 8 / 300 / (100 * 1000 * 1000 * 1000) * 100"
      return_data = true
    },
  ]
}
```

Equivalent via the root dispatcher: same inputs, plus `type = "metric-alarm"`,
`source` pointed at the repo root instead of `//modules/metric-alarm`.

## The `metrics` shape

One list, two uses:

- **A single entry with no `expression`** is rendered as a plain
  `metric_name`/`namespace` alarm - no `metric_query` block at all.
- **Two or more entries, or any entry with `expression` set**, are each
  rendered as a `metric_query` block. Every entry needs its own `id` once
  there's more than one; an `expression` entry combines the others by
  referencing their `id`s instead of setting `namespace`/`metric_name`.

`stat` defaults to `"Sum"` per entry; `return_data` defaults to `true` for
a lone entry or an expression entry, `false` otherwise - the common case
("show me the one computed line") needs no annotation.

## Query mode

`query` is an alternative to setting `comparison_operator`/`metrics`
directly, resolved via
[terraform-provider-cwquery](https://github.com/rafalmasiarek/terraform-provider-cwquery) -
exactly one of `query` or (`comparison_operator` + `metrics`) must be set.
It's an additional convenience, not a replacement: the direct, typed
interface above is unaffected and remains the primary way to use this
module.

A plain comparison with a percentile stat:

```hcl
module "alb_p99_latency" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=v0.1.0"

  name               = "alb-p99-latency"
  evaluation_periods = 3

  query = <<-EOT
    SELECT p99(Latency) FROM AWS/ApplicationELB
    WHERE LoadBalancer = 'app/my-alb/abc123'
    HAVING value > 500
  EOT
}
```

An anomaly-detection alarm - a band around a predicted value, not a plain
threshold:

```hcl
module "asg_cpu_anomaly" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=v0.1.0"

  name               = "asg-cpu-anomaly"
  evaluation_periods = 3

  query = <<-EOT
    SELECT CPUUtilization FROM AWS/EC2
    WHERE AutoScalingGroupName = 'my-asg'
    HAVING value OUTSIDE BAND(2)
  EOT
}
```

See `terraform-provider-cwquery`'s `docs/grammar-spec.md` for the full
grammar (simple comparisons, metric math, anomaly detection - composite
AND/OR/NOT alarms go through `modules/composite-alarm` instead, not this
module).

## Naming

`name` becomes `alarm_name`, made unique per account+region the same way as
every other resource in this family: via
[terraform-null-tagger](https://github.com/rafalmasiarek/terraform-null-tagger)'s
`computed_name` when `use_tagger = true` (the default), or used as-is -
caller responsible for uniqueness - when `use_tagger = false`.
