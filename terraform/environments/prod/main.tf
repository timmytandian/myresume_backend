locals {
  env = "prod"
}

# default provider; provides ap-northeast-1 resource
provider "aws" {
  region = "ap-northeast-1" # Replace with your desired region

  default_tags {
    tags = {
      environment = local.env
      project     = "myresume_backend"
      managedBy   = "terraform"
    }
  }
}


module "dynamodb" {
  source              = "../../modules/dynamodb"
  env                 = local.env
  dynamodb_table_name = "cloud_resume"
}


module "lambda" {
  source                         = "../../modules/lambda"
  env                            = local.env
  lambda_code_function_name_base = "dynamodb-resume_visitor-api_http-counts"
  lambda_layer_name_base         = "myresume_backend_layer_from_terraform"
  dynamodb_table_name            = module.dynamodb.dynamodb_table_name
}

/*
module "api_gateway" {
  source = "../../modules/api_gateway"
}*/