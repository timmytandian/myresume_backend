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
  source                   = "../../modules/dynamodb"
  env                      = local.env
  dyanmodb_table_name_base = "cloud_resume"
  //is_initialize_table_item = false
}


module "lambda" {
  source                         = "../../modules/lambda"
  env                            = local.env
  lambda_code_function_name_base = "dynamodb-resume_visitor-api_http-counts"
  lambda_layer_name_base         = "myresume_backend_layer_from_terraform"
  dynamodb_table_name            = module.dynamodb.dynamodb_table_name
}

module "api_gateway" {
  source               = "../../modules/api_gateway"
  env                  = local.env
  lambda_invoke_arn    = module.lambda.lambda_function_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name
  api_gw_name_base     = "http-myresumevisitor-dynamodb-api"
  s3_website_name      = "dev.resume.timmytandian.com" 
}
