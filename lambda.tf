module "redis_connection_cleanup" {
  source = "terraform-aws-modules/lambda/aws"

  function_name                     = "${var.name}-redis-idle-connection-cleanup"
  description                       = "Lambda for closing idle redis connections"
  handler                           = "index.lambda_handler"
  runtime                           = "nodejs14.x"
  source_path                       = "${path.module}/lambda"
  memory_size                       = 256
  timeout                           = 300
  vpc_security_group_ids            = var.vpc_security_group_ids
  vpc_subnet_ids                    = var.vpc_subnet_ids
  publish                           = false
  use_existing_cloudwatch_log_group = false
  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 14
  attach_network_policy             = true
  attach_policy_statements          = true
  policy_statements = {
    Elasticache_DescribeCacheClusters = {
      effect    = "Allow",
      actions   = ["elasticache:DescribeCacheClusters"],
      resources = ["*"]
    }
  }
  environment_variables = {
    REGION                   = data.aws_region.current.name
    IDLE_THRESHOLD_SECONDS   = var.idle_connection_threshold_seconds
    CONCURRENT_REQUEST_LIMIT = var.concurrent_request_limit
    DRY_RUN                  = var.dry_run
  }

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_sns" {
  count = var.schedule_expression == "" ? 0 : 1
  
  statement_id  = "AllowExecutionFromSns"
  action        = "lambda:InvokeFunction"
  function_name = module.redis_connection_cleanup.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.redis_idle_connection_cleanup[0].arn
}
