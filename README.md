<!-- BEGIN_TF_DOCS -->
# terraform-aws-redis-idle-connection-cleanup
GitHub: [StratusGrid/terraform-aws-redis-idle-connection-cleanup](https://github.com/StratusGrid/terraform-aws-redis-idle-connection-cleanup)
## Example
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
## StratusGrid Standards we assume
- All resource names and name tags shall use `_` and not `-`s
- The old naming standard for common files such as inputs, outputs, providers, etc was to prefix them with a `-`, this is no longer true as it's not POSIX compliant. Our pre-commit hooks will fail with this old standard.
- StratusGrid generally follows the TerraForm standards outlined [here](https://www.terraform-best-practices.com/naming)
## Repo Knowledge
Lambda triggered on a scheduleto cleanup idle redis connection based on idle threshold input value. Can optionally create alarms from a list of elasticache node names and sns topic arn.
### Future Improvements
Unit tests for client list response parsing in getConnectedClients
Support for list of secret manager arns as an environment variable for clusters/nodes requiring authentication
## Documentation
This repo is self documenting via Terraform Docs, please see the note at the bottom.
### `LICENSE`
This is the standard Apache 2.0 License as defined [here](https://stratusgrid.atlassian.net/wiki/spaces/TK/pages/2121728017/StratusGrid+Terraform+Module+Requirements).
### `outputs.tf`
The StratusGrid standard for Terraform Outputs.
### `README.md`
It's this file! I'm always updated via TF Docs!
### `tags.tf`
The StratusGrid standard for provider/module level tagging. This file contains logic to always merge the repo URL.
### `variables.tf`
All variables related to this repo for all facets.
One day this should be broken up into each file, maybe maybe not.
### `versions.tf`
This file contains the required providers and their versions. Providers need to be specified otherwise provider overrides can not be done.
## Documentation of Misc Config Files
This section is supposed to outline what the misc configuration files do and what is there purpose
### `.config/.terraform-docs.yml`
This file auto generates your `README.md` file.
### `.github/workflows/pre-commit.yml`
This file contains the instructions for Github workflows, in specific this file run pre-commit and will allow the PR to pass or fail. This is a safety check and extras for if pre-commit isn't run locally.
### `examples/*`
The files in here are used by `.config/terraform-docs.yml` for generating the `README.md`. All files must end in `.tfnot` so Terraform validate doesn't trip on them since they're purely example files.
### `.gitignore`
This is your gitignore, and contains a slew of default standards.
---
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
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
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | Lambda ARN |
---
Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->