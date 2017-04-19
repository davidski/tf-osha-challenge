home_ip = "174.21.52.72"
aws_region = "us-east-1"

terragrunt = {
  # Configure Terragrunt to use DynamoDB for locking
  lock = {
    backend = "dynamodb"
    config {
      state_file_id = "osha-challenge"
      region = "us-west-2"
    }
  }

  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state = {
    backend = "s3"
    config {
      encrypt = "true"
      bucket = "infrastructure-severski"
      key = "terraform/osha-challenge.tfstate"
      region = "us-west-2"
    }
  }
}