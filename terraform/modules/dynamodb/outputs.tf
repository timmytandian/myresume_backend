output "dynamodb_table_name" {
  value       = aws_dynamodb_table.visitors_count_db.name
  description = "The name of DynamoDB table that holds the visitors count."
}

output "dynamodb_pkey_uuid" {
  value       = local.pkey_uuid
  description = "The UUID (primary key) of the home page in DynamoDB table."
}

output "dynamodb_page_name" {
  value       = local.page_name
  description = "The page name of the home page in DynamoDB table."
}

output "dynamodb_visit_count" {
  value       = local.visit_count
  description = "The number of visits recorded in DynamoDB table."
}