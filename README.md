# OSHA-Challenge Terraform-based Infrastruscture

Sets up a RedShift/ML environment for testing with the OSHA data challenge.

The AWS environment includes:
- A VPC containing:
  - A single subnet
  - An internet gateway attached to the default route table
  - A VPC endpoint to S3
  - A RedShift instance running the dc1.large node-type and publicly accessible to a single IP
- A shutdown-on-idle solution for the ML realtime endpoint
  - CloudWatch Alarm on the realtime endpoint, set for 45 minutes of inactivity
  - A SNS topic to recieve alarms
  - A Lambda function to receive the SNS message and perform the endpoint shutdown

# Instructions

Prerequisites:
- [Terraform](https://www.terraform.io) installed locally
    - Developed with Terraform v0.7.x
- [Terragrunt](https://github.com/gruntwork-io/terragrunt) installed locally
- AWS credentials configured in the standard environment variables with permission to 
create/modify/delete all of the above resources.

## Generic

1. Clone repository.
2. Edit `.terragrunt` with locking information for your enviromnent.
3. `terragrunt get`
4. `terragrunt apply`
5. Develop!

## PowerShell Specific

1. Clone repository.
2. `terraform get`
3. `.\tf1 apply` - Uses https://ipify.com to detect external IP address and send to terraform
4. Develop!
