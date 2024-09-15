# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "dynamodb_table_name" {
  description = "The name of dynamo db table that holds visitor count"
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

