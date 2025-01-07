# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "env" {
  description = "The name of environment (dev/prod) to apply."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda function's ARN to be used for invoking it from API Gateway."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of lambda function to be invoked by this API Gateway."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "api_gw_name_base" {
  description = "The name of API Gateway that can call Lambda function to reads and updates visitor count."
  type        = string
  default     = "http-myresumevisitor-dynamodb-api"
}

variable "s3_website_name" {
  description = "The name of S3 bucket that we want to allow calling this API Gateway (CORS)."
  type        = string
  default     = "dev.timmytandian.com"
}
