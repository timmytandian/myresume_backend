locals {
  env = "dev"
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
  dyanmodb_table_name = "cloud_resume"
  //is_initialize_table_item = false
}


module "lambda" {
  source                    = "../../modules/lambda"
  env                       = local.env
  lambda_code_function_name = "dynamodb-resume_visitor-api_http-counts"
}
/*
module "api_gateway" {
  source = "../../modules/api_gateway"
}*/