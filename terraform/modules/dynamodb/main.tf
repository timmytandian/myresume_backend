resource "aws_dynamodb_table" "visitors_count_db" {
  name                        = "${var.env == "prod" ? "" : "${var.env}."}${var.dyanmodb_table_name}"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  hash_key                    = "pkey_uuid"
  range_key                   = "visit_count"

  attribute {
    name = "pkey_uuid"
    type = "S"
  }
  attribute {
    name = "visit_count"
    type = "N"
  }
}