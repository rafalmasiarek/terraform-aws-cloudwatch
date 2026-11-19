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
