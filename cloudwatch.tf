resource "aws_cloudwatch_metric_alarm" "elasticache_connection_limit" {
  for_each = toset(var.redis_nodes_for_alarms)

  alarm_name                = "${each.key}-nearing-elasticache-connection-limit"
  actions_enabled           = true
  alarm_description         = "Alarm for cluster ${each.key} nearing Elasticache connection limit"
  comparison_operator       = "GreaterThanThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  threshold                 = 55000
  treat_missing_data        = "missing"
  insufficient_data_actions = []
  ok_actions                = [var.alarm_sns_topic]
  alarm_actions             = [var.alarm_sns_topic]
  tags                      = merge(local.common_tags, {})

  metric_name = "CurrConnections"
  namespace   = "AWS/ElastiCache"
  period      = 300
  statistic   = "Maximum"

  dimensions = {
    "CacheClusterId" = each.key
  }
}