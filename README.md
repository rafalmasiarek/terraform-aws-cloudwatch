# terraform-aws-cloudwatch
![](https://raw.githubusercontent.com/rafalmasiarek/readme-gen/main/banners/.gitkeep)

## About

Shared CloudWatch building blocks for this module family: safely-named
log groups, metric alarms, and composite alarms, used internally by
sibling modules (`terraform-aws-nat-gateway`,
`terraform-aws-ec2-autoscale-group`, ...) and callable directly. This
root module is a convenience dispatcher (`var.type`) over
[modules/log-group](modules/log-group),
[modules/metric-alarm](modules/metric-alarm), and
[modules/composite-alarm](modules/composite-alarm) - calling any
submodule directly works exactly the same way. `modules/metric-alarm`
and `modules/composite-alarm` also accept an optional SQL-like `query`
string, parsed by
[terraform-provider-cwquery](https://github.com/rafalmasiarek/terraform-provider-cwquery),
as an alternative to their typed fields.



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
See [LICENSE](LICENSE) for full details.
## Authors

- Rafał Masiarek | [website](https://masiarek.pl) | [email](mailto:rafal@masiarek.pl) | [github](https://github.com/rafalmasiarek)


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
| <a name="module_composite_alarm"></a> [composite\_alarm](#module\_composite\_alarm) | ./modules/composite-alarm | n/a |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | ./modules/log-group | n/a |
| <a name="module_metric_alarm"></a> [metric\_alarm](#module\_metric\_alarm) | ./modules/metric-alarm | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_actions_enabled"></a> [actions\_enabled](#input\_actions\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description) | n/a | `string` | `null` | no |
| <a name="input_alarm_rule"></a> [alarm\_rule](#input\_alarm\_rule) | n/a | `string` | `null` | no |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | n/a | `string` | `null` | no |
| <a name="input_datapoints_to_alarm"></a> [datapoints\_to\_alarm](#input\_datapoints\_to\_alarm) | n/a | `number` | `null` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | n/a | `number` | `null` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | n/a | `string` | `null` | no |
| <a name="input_log_group_class"></a> [log\_group\_class](#input\_log\_group\_class) | n/a | `string` | `null` | no |
| <a name="input_metrics"></a> [metrics](#input\_metrics) | n/a | <pre>list(object({<br/>    id          = optional(string)<br/>    namespace   = optional(string)<br/>    metric_name = optional(string)<br/>    stat        = optional(string, "Sum")<br/>    unit        = optional(string)<br/>    dimensions  = optional(map(string), {})<br/>    expression  = optional(string)<br/>    return_data = optional(bool)<br/>  }))</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Semantic resource name - see modules/log-group or modules/metric-alarm for exactly how it's used. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_period_seconds"></a> [period\_seconds](#input\_period\_seconds) | n/a | `number` | `300` | no |
| <a name="input_query"></a> [query](#input\_query) | n/a | `string` | `null` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | n/a | `number` | `null` | no |
| <a name="input_service"></a> [service](#input\_service) | n/a | `string` | `null` | no |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | n/a | `bool` | `false` | no |
| <a name="input_tagger_context"></a> [tagger\_context](#input\_tagger\_context) | n/a | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | n/a | `number` | `null` | no |
| <a name="input_threshold_metric_id"></a> [threshold\_metric\_id](#input\_threshold\_metric\_id) | n/a | `string` | `null` | no |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | n/a | `string` | `"missing"` | no |
| <a name="input_type"></a> [type](#input\_type) | Which submodule to instantiate: "log-group", "metric-alarm", or "composite-alarm". Calling modules/log-group, modules/metric-alarm, or modules/composite-alarm directly still works too - this is a convenience dispatcher, not a replacement. | `string` | n/a | yes |
| <a name="input_use_tagger"></a> [use\_tagger](#input\_use\_tagger) | n/a | `bool` | `true` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_arn"></a> [alarm\_arn](#output\_alarm\_arn) | n/a |
| <a name="output_alarm_name"></a> [alarm\_name](#output\_alarm\_name) | n/a |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | n/a |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | n/a |


<!-- references -->

[repo_link]: https://github.com/rafalmasiarek/terraform-aws-cloudwatch
