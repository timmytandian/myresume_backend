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
}

/*
module "lambda" {
  source = "../../modules/lambda"
}*/
/*
module "api_gateway" {
  source = "../../modules/api_gateway"
}*/