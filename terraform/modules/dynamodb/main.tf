# DYNAMO DB TABLE
resource "aws_dynamodb_table" "visitors_count_db" {
  name                        = "${var.dynamodb_table_name}${var.env == "prod" ? "" : "_${var.env}"}"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  hash_key                    = "pkey_uuid"

  attribute {
    name = "pkey_uuid"
    type = "S"
  }
}

# TABLE ITEM to track visitor count (NOT MANAGED IN TERRAFORM)
data "aws_dynamodb_table_item" "visitors_count" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  key        = <<KEY
{
    "pkey_uuid": {"S": "6632d5b4-5655-4c48-b7b6-071d5823c888"}
}
KEY
}

# TABLE ITEM to make sure page_name is unique (NOT MANAGED IN TERRAFORM)
data "aws_dynamodb_table_item" "unique_home_page_name" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  key        = <<KEY
{
    "pkey_uuid": {"S": "page_name#home"}
}
KEY
}

# Local variable as output of this module
locals {
  item_data   = jsondecode(data.aws_dynamodb_table_item.visitors_count.item)
  pkey_uuid   = try(local.item_data.pkey_uuid.S, "")
  page_name   = try(local.item_data.page_name.S, "")
  visit_count = try(local.item_data.visit_count.N, 0)
}