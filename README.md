# Elasticache Idle Connection Cleanup
Lambda triggered on a scheduleto cleanup idle redis connection based on idle threshold input value.
Can optionally create alarms from a list of elasticache node names and sns topic arn.

### Example Usage
```
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

### Future Improvements
- Unit tests for client list response parsing in getConnectedClients
- Support for list of secret manager arns as an environment variable for clusters/nodes requiring authentication
