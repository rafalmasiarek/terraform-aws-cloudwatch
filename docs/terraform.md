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