resource "aws_dynamodb_table" "visitors_count_db" {
  name                        = "${var.dyanmodb_table_name}${var.env == "prod" ? "" : "_${var.env}"}"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  hash_key                    = "pkey_uuid"

  attribute {
    name = "pkey_uuid"
    type = "S"
  }
}


# Try to check if the uuid of home already existed or not
data "aws_dynamodb_table_item" "visitors_count" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  key = <<KEY
{
    "pkey_uuid": {"S": "08fc4e15-90c4-5611-e95c-05d7e4aa34e2"},
}
KEY

  # This will cause the data source to fail if the bucket doesn't exist
  count = length(aws_dynamodb_table_item.visit_count) == 0 ? 1 : 0
}

# Try to check if the uuid of home already existed or not
data "aws_dynamodb_table_item" "unique_home_page_name" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  key = <<KEY
{
    "pkey_uuid": {"S": "page_name#home"},
}
KEY

  # This will cause the data source to fail if the bucket doesn't exist
  count = length(aws_dynamodb_table_item.unique_home_page_name) == 0 ? 1 : 0
}

# Initialize Random UUID to be used as the home pkey_uuid
resource "random_uuid" "home_pkey_uuid" {
  count = length(data.aws_dynamodb_table_item.visitors_count) == 0 ? 1 : 0
}

# Initialize the table item that represent the visitor count
resource "aws_dynamodb_table_item" "visit_count" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  hash_key   = aws_dynamodb_table.visitors_count_db.hash_key

  item = <<ITEM
{
  "pkey_uuid": {"S": "${random_uuid.home_pkey_uuid.result}"},
  "visit_count": {"N": "0"},
  "page_name": {"S": "home"}
}
ITEM

  # Only create if the data source failed 
  # i.e., "aws_dynamodb_table_item.visitors_count" doesn't exist
  count = length(data.aws_dynamodb_table_item.visit_count) == 0 ? 1 : 0
  depends_on = [random_uuid.home_pkey_uuid]
}

# Initialize a table item to make sure that "home" value in "page_name" column is unique
resource "aws_dynamodb_table_item" "unique_home_page_name" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  hash_key   = aws_dynamodb_table.visitors_count_db.hash_key

  item = <<ITEM
{
  "pkey_uuid": {"S": "page_name#home"}
}
ITEM

  # Only create if the data source failed 
  # i.e., "aws_dynamodb_table_item.visitors_count" doesn't exist
  count = length(data.aws_dynamodb_table_item.unique_home_page_name) == 0 ? 1 : 0
}