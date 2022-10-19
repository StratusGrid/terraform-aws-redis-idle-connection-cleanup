output "lambda_arn" {
  description = "Lambda ARN"
  value       = module.redis_connection_cleanup.lambda_function_arn
}
