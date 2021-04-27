resource "aws_cloudwatch_event_target" "redis_idle_connection_cleanup" {
  count = var.schedule_expression == "" ? 0 : 1

  target_id = "${var.name}-redis-idle-connection-cleanup"
  rule      = aws_cloudwatch_event_rule.redis_idle_connection_cleanup[0].name
  arn       = module.redis_connection_cleanup.lambda_function_arn
}

resource "aws_cloudwatch_event_rule" "redis_idle_connection_cleanup" {
  count = var.schedule_expression == "" ? 0 : 1

  name                = "${var.name}-redis-idle-connection-cleanup-trigger"
  description         = "Rule to trigger redis connection cleanup lambda"
  schedule_expression = var.schedule_expression
  tags                = local.common_tags
}
