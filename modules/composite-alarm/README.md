# terraform-aws-cloudwatch/modules/composite-alarm
![](https://raw.githubusercontent.com/rafalmasiarek/readme-gen/main/banners/.gitkeep)

## About

A single `aws_cloudwatch_composite_alarm` - boolean AND/OR/NOT
composition over alarms already defined elsewhere (typically with
[modules/metric-alarm](../metric-alarm)), plus the same tagger-driven
unique naming used across this module family. Part of
[terraform-aws-cloudwatch](../../); calling it directly works exactly
the same as going through the root dispatcher with
`type = "composite-alarm"`.



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

Via `query` - a cwquery composite expression (see
[terraform-provider-cwquery](https://github.com/rafalmasiarek/terraform-provider-cwquery)'s
`docs/grammar-spec.md` for the full grammar):

```hcl
module "nat_combined" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/composite-alarm?ref=v0.1.0"

  name = "nat-a-combined"

  query = "(ALARM(\"${module.cpu_high.alarm_name}\") OR ALARM(\"${module.memory_high.alarm_name}\")) AND NOT ALARM(\"${module.maintenance_window.alarm_name}\")"
}
```

Note that the alarm names inside `ALARM("...")` are resolved by ordinary
Terraform string interpolation (`${module.x.alarm_name}`) before the
string ever reaches `cwquery` - the parser itself has no knowledge of the
Terraform resource graph, it only ever sees the final literal string.

Via `alarm_rule` directly - AWS's own `alarm_rule` syntax, bypassing
`cwquery` entirely:

```hcl
module "nat_combined_direct" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/composite-alarm?ref=v0.1.0"

  name       = "nat-a-combined-direct"
  alarm_rule = "ALARM(\"${module.cpu_high.alarm_name}\") AND ALARM(\"${module.memory_high.alarm_name}\")"
}
```

Equivalent via the root dispatcher: same inputs, plus
`type = "composite-alarm"`, `source` pointed at the repo root instead of
`//modules/composite-alarm`.

## The `query`/`alarm_rule` shape

Exactly one of `query` or `alarm_rule` must be set - two alternative,
mutually exclusive ways to define the same thing. `query` only accepts a
*composite* cwquery expression (`ALARM(...)` combined with
`AND`/`OR`/`NOT`) - feeding it a `SELECT ...` metric query instead is
rejected at `terraform plan` (that belongs in
[modules/metric-alarm](../metric-alarm), not here).

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
| [aws_cloudwatch_composite_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_composite_alarm) | resource |
| tagger_origin.self | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_actions_enabled"></a> [actions\_enabled](#input\_actions\_enabled) | Native aws\_cloudwatch\_composite\_alarm field - set false to temporarily suspend action-triggering without deleting the alarm. | `bool` | `true` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description) | n/a | `string` | `null` | no |
| <a name="input_alarm_rule"></a> [alarm\_rule](#input\_alarm\_rule) | Direct AWS alarm\_rule syntax (e.g. "ALARM(\"x\") AND ALARM(\"y\")"), bypassing cwquery entirely. Not used when query is set. | `string` | `null` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Semantic alarm name, including whatever resource-type infix the caller needs for clarity - made globally unique via the tagger when use\_tagger = true (alarm\_name must be unique per account+region, and this string alone is not). | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | n/a | `list(string)` | `[]` | no |
| <a name="input_query"></a> [query](#input\_query) | A cwquery composite string (ALARM(...)/AND/OR/NOT - see terraform-provider-cwquery) - an alternative to setting alarm\_rule directly. Exactly one of query or alarm\_rule must be set. | `string` | `null` | no |
| <a name="input_tagger_additional_services"></a> [tagger\_additional\_services](#input\_tagger\_additional\_services) | Extra terraform-null-tagger `service` data per taggable resource, keyed by the same key as local.taggable (e.g. "subnet-public-a"). Merged on top of what this module computes automatically - lets a caller tag something this module doesn't know about, without waiting for a new module release. | `any` | `{}` | no |
| <a name="input_tagger_context"></a> [tagger\_context](#input\_tagger\_context) | module.tagger.context from the root stack's base terraform-null-tagger call. | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource(s). | `map(string)` | `{}` | no |
| <a name="input_use_tagger"></a> [use\_tagger](#input\_use\_tagger) | Compute and apply standardized tags via terraform-null-tagger. When false, use var.tags as-is instead. | `bool` | `true` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_arn"></a> [alarm\_arn](#output\_alarm\_arn) | n/a |
| <a name="output_alarm_name"></a> [alarm\_name](#output\_alarm\_name) | The final, tagger-made-unique name actually given to the alarm - not necessarily var.name as-is. |



<!-- references -->

[repo_link]: https://github.com/rafalmasiarek/terraform-aws-cloudwatch
