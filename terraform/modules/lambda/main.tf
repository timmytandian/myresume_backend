##################################################################
## IAM Role and Permission
##################################################################
# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_code" {
  name = "dynamodb-query-myresumevisitors-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic Lambda execution policy to the IAM role above
resource "aws_iam_role_policy_attachment" "lambda_code_basic" {
  policy_arn = "arn:aws:iam::966337238076:policy/service-role/AWSLambdaBasicExecutionRole-b0916520-43c9-4c0c-9fc2-83fd430db7cf"
  role       = aws_iam_role.lambda_code.name
}

# Attach Lambda execution policy to enable read & write onto the DynamoDB table
# The policy itself is not managed in Terraform
resource "aws_iam_role_policy_attachment" "lambda_code_dynamodb" {
  policy_arn = "arn:aws:iam::966337238076:policy/dynamodb-readwrite-cloudresume_visitors"
  role       = aws_iam_role.lambda_code.name
}

##################################################################
## Python code Lambda function
##################################################################
data "archive_file" "lambda_code" {
  type        = "zip"
  output_path = "/tmp/myresume_backend/lambda_code.zip"
  source_dir  = "${path.module}/../../../myresume_backend"
  excludes = [
    "__pycache__",
    ".pytest_cache",
  ]
}

resource "aws_lambda_function" "lambda_code" {
  function_name    = "${var.lambda_code_function_name}${var.env == "prod" ? "" : "_${var.env}"}"
  description      = "[main_use, ${var.env}] This function reads and updates DynamoDB cloud_resume table. Connected with API Gateway HTTP API at the front. API route: /counts/{page-id}."
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  handler = "lambda_function.lambda_handler"
  runtime = "python3.11"
  role    = aws_iam_role.lambda_code.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = "cloud_resume"
    }
  }
}

##################################################################
## Dependencies Lambda Layer
##################################################################
resource "null_resource" "lambda_layer" {
  provisioner "local-exec" {
    command = <<EOT
      cd ${path.module}/../../../
      mkdir -p aws_layer/python/lib/python3.11/site-packages
      poetry export -f requirements.txt --output requirements.txt
      pip install -r requirements.txt -t aws_layer/python/lib/python3.11/site-packages
    EOT
  }

  triggers = {
    dependencies_versions = filemd5("${path.module}/../../../pyproject.toml")
  }
}

data "archive_file" "lambda_layer" {
  type        = "zip"
  output_path = "/tmp/myresume_backend/lambda_layer.zip"
  source_dir  = "${path.module}/../../../aws_layer"
  excludes    = ["*.pyc"]
  depends_on  = [null_resource.lambda_layer]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "${var.lambda_layer_name}${var.env == "prod" ? "" : "_${var.env}"}"
  filename            = data.archive_file.lambda_layer.output_path
  compatible_runtimes = ["python3.11"]
}