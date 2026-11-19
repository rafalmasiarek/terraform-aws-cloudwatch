# terraform-aws-cloudwatch/modules/metric-alarm
![](https://raw.githubusercontent.com/rafalmasiarek/readme-gen/main/banners/.gitkeep)

## About

A single `aws_cloudwatch_metric_alarm` with a simplified, uniform
`metrics` list shape covering both the plain metric_name/namespace case
and multi-metric math expressions, plus the same tagger-driven unique
naming used across this module family. Part of
[terraform-aws-cloudwatch](../../); calling it directly works exactly
the same as going through the root dispatcher with
`type = "metric-alarm"`.



## License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```text
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files, to deal in the Software
without restriction.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

Source: https://opensource.org/licenses/MIT
```
## Authors

- Rafał Masiarek | [website](https://masiarek.pl) | [email](mailto:rafal@masiarek.pl) | [github](https://github.com/rafalmasiarek)


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


## Terraform Reference



### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_cwquery"></a> [cwquery](#requirement\_cwquery) | >= 0.1.0 |
| <a name="requirement_tagger"></a> [tagger](#requirement\_tagger) | >= 0.1.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_tagger"></a> [tagger](#module\_tagger) | rafalmasiarek/tagger/null | >= 0.5.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| tagger_origin.self | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_actions_enabled"></a> [actions\_enabled](#input\_actions\_enabled) | Native aws\_cloudwatch\_metric\_alarm field - set false to temporarily suspend action-triggering without deleting the alarm. | `bool` | `true` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description) | n/a | `string` | `null` | no |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | "GreaterThanThreshold" \| "GreaterThanOrEqualToThreshold" \| "LessThanThreshold" \| "LessThanOrEqualToThreshold" \| "LessThanLowerOrGreaterThanUpperThreshold" \| "LessThanLowerThreshold" \| "GreaterThanUpperThreshold". Not used when query is set. | `string` | `null` | no |
| <a name="input_datapoints_to_alarm"></a> [datapoints\_to\_alarm](#input\_datapoints\_to\_alarm) | Defaults to evaluation\_periods (every period must breach) when unset. | `number` | `null` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | n/a | `number` | n/a | yes |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_metrics"></a> [metrics](#input\_metrics) | One or more metrics. A single entry with no `expression` is used directly as a<br/>plain metric\_name/namespace alarm - no metric\_query involved. Two or more entries,<br/>or any entry with `expression` set, produce one metric\_query block per entry<br/>(expression entries combine the others by their `id`). | <pre>list(object({<br/>    id          = optional(string) # required when metrics has >1 entry, or referenced by another entry's expression<br/>    namespace   = optional(string) # required unless this entry is itself an expression<br/>    metric_name = optional(string) # required unless this entry is itself an expression<br/>    stat        = optional(string, "Sum")<br/>    unit        = optional(string)<br/>    dimensions  = optional(map(string), {})<br/>    expression  = optional(string) # set instead of namespace/metric_name - combines other entries' ids<br/>    return_data = optional(bool)   # default: true for a lone entry or an expression entry, false otherwise<br/>  }))</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Semantic alarm name, including whatever resource-type infix the caller needs for clarity (e.g. "nat-a-error-port-allocation") - made globally unique via the tagger when use\_tagger = true (alarm\_name must be unique per account+region, and this string alone is not). | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_period_seconds"></a> [period\_seconds](#input\_period\_seconds) | Shared across every entry in metrics - CloudWatch alarms evaluate all their metrics over the same period. | `number` | `300` | no |
| <a name="input_query"></a> [query](#input\_query) | A cwquery string (see terraform-provider-cwquery) - an alternative to setting comparison\_operator/metrics directly. Exactly one of query or (comparison\_operator + metrics) must be set. | `string` | `null` | no |
| <a name="input_tagger_additional_services"></a> [tagger\_additional\_services](#input\_tagger\_additional\_services) | Extra terraform-null-tagger `service` data per taggable resource, keyed by the same key as local.taggable (e.g. "subnet-public-a"). Merged on top of what this module computes automatically - lets a caller tag something this module doesn't know about, without waiting for a new module release. | `any` | `{}` | no |
| <a name="input_tagger_context"></a> [tagger\_context](#input\_tagger\_context) | module.tagger.context from the root stack's base terraform-null-tagger call. | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource(s). | `map(string)` | `{}` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | Not used when query is set, or when using threshold\_metric\_id directly. | `number` | `null` | no |
| <a name="input_threshold_metric_id"></a> [threshold\_metric\_id](#input\_threshold\_metric\_id) | id of a metrics entry whose expression is ANOMALY\_DETECTION\_BAND(...) - used instead of threshold for anomaly-detection alarms. Not used when query is set (an anomaly-detection query already resolves this itself). | `string` | `null` | no |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | n/a | `string` | `"missing"` | no |
| <a name="input_use_tagger"></a> [use\_tagger](#input\_use\_tagger) | Compute and apply standardized tags via terraform-null-tagger. When false, use var.tags as-is instead. | `bool` | `true` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_arn"></a> [alarm\_arn](#output\_alarm\_arn) | n/a |
| <a name="output_alarm_name"></a> [alarm\_name](#output\_alarm\_name) | The final, tagger-made-unique name actually given to the alarm - not necessarily var.name as-is. |



<!-- references -->

[repo_link]: https://github.com/rafalmasiarek/terraform-aws-cloudwatch
