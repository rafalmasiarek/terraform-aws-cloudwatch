# terraform-aws-cloudwatch/modules/log-group
![](https://raw.githubusercontent.com/rafalmasiarek/readme-gen/main/banners/.gitkeep)

## About

A single `aws_cloudwatch_log_group` with safe naming built in: the name
is always `/${service}/${name}`, `name` is made unique per
account+region via the tagger when `use_tagger = true`, and `aws/`-prefixed
names are rejected at `terraform plan` (the `CreateLogGroup` API rejects
them at apply time anyway - this module just catches it earlier). Part of
[terraform-aws-cloudwatch](../../); calling it directly works exactly the
same as going through the root dispatcher with `type = "log-group"`.



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

```hcl
module "ecs_log_group" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git//modules/log-group?ref=v0.1.0"

  service           = "ecs"
  name              = "myapp"
  retention_in_days = 30
}
```

Equivalent via the root dispatcher:

```hcl
module "ecs_log_group" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-cloudwatch.git?ref=v0.1.0"

  type              = "log-group"
  service           = "ecs"
  name              = "myapp"
  retention_in_days = 30
}
```

## Naming

The final log group name is always `/${service}/${name}`. `service` is a
plain grouping segment shared across environments/deployments (e.g. `"ecs"`,
`"vpc"`, `"nat"`) - no environment or namespace information belongs there.
`name` carries that information instead: with `use_tagger = true` (the
default) it's replaced by
[terraform-null-tagger](https://github.com/rafalmasiarek/terraform-null-tagger)'s
`computed_name`, which is namespace/environment-aware and unique by
construction. With `use_tagger = false`, `name` is used as given and the
caller is responsible for its uniqueness within `service`.

`name` can never start with `aws/` - that prefix is reserved for
AWS-managed log groups (e.g. the ones Lambda creates for itself) and is
rejected outright by the `CreateLogGroup` API. This module validates that
at `terraform plan`, not at `apply`.

## Retention

`retention_in_days` has no default on purpose: CloudWatch's own default
behavior for an unset retention is "never expire," which should never be
an implicit, silent choice for a log group a caller is creating.


## Terraform Reference



### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_tagger"></a> [tagger](#requirement\_tagger) | >= 0.1.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_tagger"></a> [tagger](#module\_tagger) | rafalmasiarek/tagger/null | >= 0.5.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| tagger_origin.self | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | n/a | `string` | `null` | no |
| <a name="input_log_group_class"></a> [log\_group\_class](#input\_log\_group\_class) | "STANDARD" (default) or "INFREQUENT\_ACCESS" (cheaper storage for logs rarely queried - no Live Tail, slower Insights queries). | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Semantic resource name, e.g. "myvpc-flow-log" - made globally unique via the tagger when use\_tagger = true (log group names must be unique per account+region, and this string alone is not). | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Required, no default - CloudWatch's own default is "never expire", which should never be a silent, implicit choice. | `number` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | Grouping segment, e.g. "vpc", "ecs", "nat" - shared across environments/deployments, used for console grouping (renders as /service/... in the log-group tree). No environment/namespace info belongs here. | `string` | n/a | yes |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | n/a | `bool` | `false` | no |
| <a name="input_tagger_additional_services"></a> [tagger\_additional\_services](#input\_tagger\_additional\_services) | Extra terraform-null-tagger `service` data per taggable resource, keyed by the same key as local.taggable (e.g. "subnet-public-a"). Merged on top of what this module computes automatically - lets a caller tag something this module doesn't know about, without waiting for a new module release. | `any` | `{}` | no |
| <a name="input_tagger_context"></a> [tagger\_context](#input\_tagger\_context) | module.tagger.context from the root stack's base terraform-null-tagger call. | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource(s). | `map(string)` | `{}` | no |
| <a name="input_use_tagger"></a> [use\_tagger](#input\_use\_tagger) | Compute and apply standardized tags via terraform-null-tagger. When false, use var.tags as-is instead. | `bool` | `true` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | n/a |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | n/a |



<!-- references -->

[repo_link]: https://github.com/rafalmasiarek/terraform-aws-cloudwatch
