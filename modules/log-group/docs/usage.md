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
