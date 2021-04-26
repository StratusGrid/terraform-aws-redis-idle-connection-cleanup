output "lambda_arn" {
    value = module.redis_connection_cleanup.this_lambda_function_arn
}
