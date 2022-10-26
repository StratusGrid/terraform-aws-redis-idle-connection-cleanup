<!-- BEGIN_TF_DOCS -->
# terraform-aws-redis-idle-connection-cleanup

GitHub: [StratusGrid/terraform-aws-redis-idle-connection-cleanup](https://github.com/StratusGrid/terraform-aws-redis-idle-connection-cleanup)

Lambda triggered on a scheduleto cleanup idle redis connection based on idle threshold input value.
Can optionally create alarms from a list of elasticache node names and sns topic arn.

## Example:
```hcl
module "redis_idle_connection_cleanup" {
  source     = StratusGrid/terraform-aws-ephemeral-environment-cleanup-lambda

  name = "${var.name_prefix}${local.name_suffix}"
  vpc_subnet_ids = data.aws_subnet_ids.private_microservices_subnets.ids
  vpc_security_group_ids = [aws_security_group.redis_idle_connection_cleanup.id]

  redis_nodes_for_alarms = ["node1", "node2"]
  sns_alarm_topic_arn = aws_sns_topic.alarm_notifications.arn
  schedule_expression = "cron(0 6 * * ? *)" // Everyday at 0600 UTC
  dry_run = false

  tags = local.common_tags
}
```
---
### Future Improvements
- Unit tests for client list response parsing in getConnectedClients
- Support for list of secret manager arns as an environment variable for clusters/nodes requiring authentication

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.redis_idle_connection_cleanup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.redis_idle_connection_cleanup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_metric_alarm.elasticache_connection_limit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_lambda_permission.allow_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_sns_topic"></a> [alarm\_sns\_topic](#input\_alarm\_sns\_topic) | (Optional) SNS topic for for connection limit alarm to send an alert | `string` | `null` | no |
| <a name="input_concurrent_request_limit"></a> [concurrent\_request\_limit](#input\_concurrent\_request\_limit) | Size of close connection batches from lambda function | `string` | `50` | no |
| <a name="input_dry_run"></a> [dry\_run](#input\_dry\_run) | Flag to set lambda into 'informational only' mode | `bool` | `true` | no |
| <a name="input_idle_connection_threshold_seconds"></a> [idle\_connection\_threshold\_seconds](#input\_idle\_connection\_threshold\_seconds) | Number of seconds to compare connection idle time against to determine whether or not to close the connection | `string` | `86400` | no |
| <a name="input_name"></a> [name](#input\_name) | String to append to resource names. | `string` | n/a | yes |
| <a name="input_redis_nodes_for_alarms"></a> [redis\_nodes\_for\_alarms](#input\_redis\_nodes\_for\_alarms) | List of nodes to assign alarms to it's CurrConnection metric | `list(string)` | `[]` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | (Optional) cron() or rate() string for triggering lambda by scheduled Eventbridge rule | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Maps of tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | list of security groups to attach to lambda | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | list of vpc subnet ids to create network interfaces for lambda | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | ARN of Lambda created |

---

<span style="color:red">Note:</span> Manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml .`
<!-- END_TF_DOCS -->