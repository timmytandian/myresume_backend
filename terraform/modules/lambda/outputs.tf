output "lambda_function_name" {
  value       = aws_lambda_function.lambda_code.function_name
  description = "The name of Lambda function that can interact with DynamoDB table."
}

output "lambda_function_arn" {
  value       = aws_lambda_function.lambda_code.arn
  description = "The ARN of Lambda function that can interact with DynamoDB table."
}

output "lambda_function_invoke_arn" {
  value       = aws_lambda_function.lambda_code.invoke_arn
  description = "The ARN of Lambda function that will be used for invoking it from API Gateway. This invoke ARN will be used in aws_api_gateway_integration's uri."
}