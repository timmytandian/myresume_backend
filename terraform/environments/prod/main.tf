provider "aws" {
  region = "ap-northeast-1"  # Replace with your desired region
  
  default_tags {
    tags = {
      project = "tf_testdrive"
      managedBy = "terraform"
    }
  }
}

resource "aws_s3_bucket" "tf_testdrive" {
  bucket = "terraform-bucket-test-7205361"  # Replace with your desired name
}

resource "aws_s3_bucket_versioning" "tf_testdrive" {
  bucket = aws_s3_bucket.tf_testdrive.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_testdrive" {
  bucket = aws_s3_bucket.tf_testdrive.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_testdrive" {
  bucket = aws_s3_bucket.tf_testdrive.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
