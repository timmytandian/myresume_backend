# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "lambda_code_function_name" {
  description = "The name of lambda function that reads and updates visitor count data in DynamoDB."
  type        = string
}

variable "env" {
  description = "The name of environment (dev/prod) to apply."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------


