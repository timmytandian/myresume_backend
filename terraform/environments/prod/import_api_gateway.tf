# Use the block below to import the resource from AWS
# IMPORTANT: after the import procedure finished, the code below should be commented out.


import {
  to = module.api_gateway.aws_apigatewayv2_api.resume_visitor_api
  id = "3ijz5acnoe"
}

import {
  to = module.api_gateway.aws_apigatewayv2_integration.resume_visitor_api
  id = "3ijz5acnoe/z5xju7u"
}

import {
  to = module.api_gateway.aws_apigatewayv2_route.get_count
  id = "3ijz5acnoe/7c6rk9c"
}

import {
  to = module.api_gateway.aws_apigatewayv2_stage.default
  id = "3ijz5acnoe/$default"
}

import {
  to = module.api_gateway.aws_lambda_permission.resume_visitor_api
  id = "dynamodb-resume_visitor-api_http-counts/02e65704-055f-5685-8c78-b6b86e9024c1"
}