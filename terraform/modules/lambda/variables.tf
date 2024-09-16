# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "env" {
  description = "The name of environment (dev/prod) to apply."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of DynamoDB table that holds the visitors count."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "lambda_code_function_name_base" {
  description = "The name of lambda function that reads and updates visitor count data in DynamoDB."
  type        = string
  default     = "dynamodb-resume_visitor-api_http-counts"
}

variable "lambda_layer_name_base" {
  description = "The name of lambda layer dependencies."
  type        = string
  default     = "myresume_backend_layer_from_github_action"
}

