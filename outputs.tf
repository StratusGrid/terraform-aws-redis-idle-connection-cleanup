output "lambda_arn" {
  description = "ARN of Lambda created"
  value       = module.redis_connection_cleanup.lambda_function_arn
}
