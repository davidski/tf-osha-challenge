# osha-terraform

Sets up a RedShift environment for testing with the OSHA data challenge.

The AWS environment includes:
- A VPC containing:
  - A single subnet
  - An internet gateway attached to the default route table
  - A VPC endpoint to S3
  - A RedShift instance running the dc1.large node-type and publicly accessible to a single IP

# Instructions

Prerequisites:
- [Terraform](https://www.terraform.io) installed locally
    - Developed with Terraform v0.7.x
- AWS credentials configured in the standard environment variables with permission to 
create/modify/delete all of the above resources.

## Generic Instance

1. Clone repository.
2. `terraform get`
3. `terraform apply`
4. Develop!

## PowerShell Specific

1. Clone repository.
2. `terraform get`
3. `.\tf1 apply` - Uses https://ipify.com to detect external IP address and send to terraform
4. Develop!


# To Dos

- Add docs about terraform remote state
