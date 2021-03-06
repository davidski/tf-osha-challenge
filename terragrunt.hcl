# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state = {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = "infrastructure-severski"
    key     = "terraform/osha-challenge.tfstate"
    region  = "us-west-2"
  }
}
