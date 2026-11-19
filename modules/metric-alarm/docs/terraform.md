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
