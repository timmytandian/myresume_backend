# Use the block below to import the resource from AWS
# IMPORTANT: after the import procedure finished, the code below should be commented out.


import {
  to = module.lambda.aws_iam_role.lambda_code
  id = "dynamodb-query-myresumevisitors-role-e5kax67j"
}

import {
  to = module.lambda.aws_iam_role_policy_attachment.lambda_code_basic
  id = "dynamodb-query-myresumevisitors-role-e5kax67j/arn:aws:iam::966337238076:policy/service-role/AWSLambdaBasicExecutionRole-b0916520-43c9-4c0c-9fc2-83fd430db7cf"
}

import {
  to = module.lambda.aws_iam_role_policy_attachment.lambda_code_dynamodb
  id = "dynamodb-query-myresumevisitors-role-e5kax67j/arn:aws:iam::966337238076:policy/dynamodb-readwrite-cloudresume_visitors"
}

import {
  to = module.lambda.aws_lambda_function.lambda_code
  id = "dynamodb-resume_visitor-api_http-counts"
}

import {
  to = module.lambda.aws_lambda_layer_version.dependencies
  id = "arn:aws:lambda:ap-northeast-1:966337238076:layer:myresume_backend_layer_from_github_action:6"
}
