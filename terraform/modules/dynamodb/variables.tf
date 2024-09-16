# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "dyanmodb_table_name_base" {
  description = "The name of dynamo db table that holds visitor count"
  type        = string
}

variable "env" {
  description = "The name of environment (dev/prod) to apply."
  type        = string
}

/*
variable "is_initialize_table_item" {
  description = "whether to initialize the dynamodb table item or not"
  type = bool
}*/

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------


