output "api_gateway_endpoint" {
  value       = module.api_gateway.api_gateway_endpoint
  description = "The endpoint URL of the API Gateway."
}

output "dynamodb_table_name" {
  value       = module.dynamodb.dynamodb_table_name
  description = "The name of DynamoDB table that holds the visitors count."
}

output "dynamodb_pkey_uuid" {
  value       = module.dynamodb.dynamodb_pkey_uuid
  description = "The UUID (primary key) of the home page in DynamoDB table."
}

output "dynamodb_page_name" {
  value       = module.dynamodb.dynamodb_page_name
  description = "The page name of the home page in DynamoDB table."
}

output "dynamodb_visit_count" {
  value       = module.dynamodb.dynamodb_visit_count
  description = "The number of visits recorded in DynamoDB table."
}

output "lambda_function_name" {
  value       = module.lambda.lambda_function_name
  description = "The name of Lambda function that can interact with DynamoDB table."
}

output "lambda_function_arn" {
  value       = module.lambda.lambda_function_arn
  description = "The name of Lambda function that can interact with DynamoDB table."
}