# NOTE: the configuration of random_uuid and 2 aws_dynamodb_table_item are applied only once,
# only applied when we initialize the Dynamo DB table. After the initialization finished, 
# we should remove them from the terraform state file. Command:
#   terraform state list // to list all resources managed by the state file
#   terraform state rm RESOURCE.ADDRESS // to remove the target resource
# After the removal finished, we should track the pkey_uuid as data resource (as output)
# so its value can be used in other modules.

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


# TODO: clean up comments.

# Try to check if the uuid of home already existed or not
data "aws_dynamodb_table_item" "visitors_count" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  key = <<KEY
{
    "pkey_uuid": {"S": "250808e1-38f9-2c29-90b9-5146319be0c3"}
}
KEY

  # This will cause the data source to fail if the bucket doesn't exist
  //count = length(aws_dynamodb_table_item.visit_count) == 0 ? 1 : 0
}

# Try to check if the uuid of home already existed or not
data "aws_dynamodb_table_item" "unique_home_page_name" {
  table_name = aws_dynamodb_table.visitors_count_db.name
  key = <<KEY
{
    "pkey_uuid": {"S": "page_name#home"}
}
KEY

  # This will cause the data source to fail if the bucket doesn't exist
  //count = length(aws_dynamodb_table_item.unique_home_page_name) == 0 ? 1 : 0
}

locals {
  item_data = jsondecode(data.aws_dynamodb_table_item.visitors_count.item)
  pkey_uuid = try(local.item_data.pkey_uuid.S, "")
  page_name = try(local.item_data.page_name.S, "")
  visit_count = try(local.item_data.visit_count.N, 0)
}


/*
# Initialize Random UUID to be used as the home pkey_uuid
resource "random_uuid" "home_pkey_uuid" {
  # Only create if the is_initialize_table_item is true
  //count = var.is_initialize_table_item ? 1 : 0
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

  # Only create if the is_initialize_table_item is true
  //count = var.is_initialize_table_item ? 1 : 0
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

  # Only create if the is_initialize_table_item is true
  //count = var.is_initialize_table_item ? 1 : 0
}*/