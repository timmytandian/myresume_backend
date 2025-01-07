output "lambda_function_name" {
  value       = aws_lambda_function.lambda_code.function_name
  description = "The name of Lambda function that can interact with DynamoDB table."
}

output "lambda_function_arn" {
  value       = aws_lambda_function.lambda_code.arn
  description = "The ARN of Lambda function that can interact with DynamoDB table."
}