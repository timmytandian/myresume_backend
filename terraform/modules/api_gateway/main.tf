# The API Gateway itself
resource "aws_apigatewayv2_api" "resume_visitor_api" {
  name          = "${var.api_gw_name_base}${var.env == "prod" ? "" : "-${var.env}"}"
  protocol_type = "HTTP"
  description   = "[main_use, ${var.env}] This API Gateway links to Lambda function that can get and update visitor count in my cloud resume."

  cors_configuration {
    allow_origins = ["http://${var.s3_website_name}", "http://www.${var.s3_website_name}"]
    allow_methods = ["GET"]
    allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
    max_age       = 300
  }
}

# API Gateway integration with Lambda Function
resource "aws_apigatewayv2_integration" "resume_visitor_api" {
  api_id                 = aws_apigatewayv2_api.resume_visitor_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
}

# API Gateway route
resource "aws_apigatewayv2_route" "get_count" {
  api_id    = aws_apigatewayv2_api.resume_visitor_api.id
  route_key = "GET /counts/{page-id}"
  target    = "integrations/${aws_apigatewayv2_integration.resume_visitor_api.id}"
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.resume_visitor_api.id
  name        = "$default"
  auto_deploy = true
}

# Lambda permission to allow API Gateway invocation
resource "aws_lambda_permission" "resume_visitor_api" {
  statement_id  = "AllowAPIGatewayInvoke-${aws_apigatewayv2_api.resume_visitor_api.name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name # aws_lambda_function.page_counter.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*" part allows invocation from any stage, method and resource path within API Gateway
  source_arn = "${aws_apigatewayv2_api.resume_visitor_api.execution_arn}/*/*"
}