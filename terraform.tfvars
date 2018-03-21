home_ip = "174.21.52.72"
aws_region = "us-east-1"

terragrunt = {
  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state = {
    backend = "s3"
    config {
      encrypt = true
      bucket = "infrastructure-severski"
      key = "terraform/osha-challenge.tfstate"
      region = "us-west-2"
    }
  }
}

