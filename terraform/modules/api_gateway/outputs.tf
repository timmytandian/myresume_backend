# Output the API endpoint URL
output "api_gateway_endpoint" {
  value       = aws_apigatewayv2_api.resume_visitor_api.api_endpoint
  description = "The endpoint URL of the API Gateway."
}