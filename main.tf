provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  assume_role {
    role_arn = "arn:aws:iam::754135023419:role/administrator-service"
  }
}

provider "aws" {
  alias   = "west"
  region  = "us-west-2"
  profile = var.aws_profile

  assume_role {
    role_arn = "arn:aws:iam::754135023419:role/administrator-service"
  }
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "terraform_remote_state" "main" {
  backend = "s3"

  config = {
    bucket  = "infrastructure-severski"
    key     = "terraform/infrastructure.tfstate"
    region  = "us-west-2"
    encrypt = "true"
  }
}

module "osha_vpc" {
  source = "git@github.com:davidski/tf-vpc.git?ref=v0.1.3"
  /*source  = "D:\\terraform\\tf-vpc"*/

  cidr         = var.vpc_cidr
  name         = var.vpc_name
  project      = var.project
  logging_role = data.terraform_remote_state.main.outputs.vpc_cloudwatch_logger_role_arn
}

module "osha_subnet" {
  source            = "git@github.com:davidski/tf-public_subnet.git?ref=v0.1.4"
  vpc_id            = module.osha_vpc.vpc_id
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_cidr       = cidrsubnet(var.vpc_cidr, 8, 1)
}

data "aws_redshift_service_account" "main" {}

data "aws_iam_policy_document" "redshift_s3_reader" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_role" "redshift_s3_reader" {
  name = "redshift_s3_reader"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "redshift.${data.aws_region.current.name}.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "redshift_s3_reader" {
  name   = "redshift_s3_reader"
  role   = aws_iam_role.redshift_s3_reader.id
  policy = data.aws_iam_policy_document.redshift_s3_reader.json
}

resource "aws_redshift_subnet_group" "osha" {
  name       = "redshift-osha"
  subnet_ids = [module.osha_subnet.subnet_id]
}

resource "aws_security_group" "redshift_from_home" {
  name_prefix = "redshift_from_home"
  vpc_id      = module.osha_vpc.vpc_id

  tags = {
    Name        = "redshift_from_home"
    description = "Allow inbound traffic from home to RedShift"
    project     = var.project
    managed_by  = "Terraform"
  }
}

/*
resource "aws_security_group_rule" "allow_from_home" {
  type              = "ingress"
  from_port         = "${aws_redshift_cluster.osha_redshift.port}"
  to_port           = "${aws_redshift_cluster.osha_redshift.port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.home_ip}/32"]
  security_group_id = "${aws_security_group.redshift_from_home.id}"
}
*/

resource "aws_security_group" "all_outbound" {
  name_prefix = "all_outbound_"
  vpc_id      = module.osha_vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "all_outbound"
    description = "Allow outbound traffic to the Internet"
    project     = var.project
    managed_by  = "Terraform"
  }
}

resource "aws_redshift_parameter_group" "osha" {
  name   = "parameter-group-osha-redshift"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "false"
  }
}

/*
resource "aws_redshift_cluster" "osha_redshift" {
  cluster_identifier           = "tf-redshift-cluster"
  cluster_parameter_group_name = aws_redshift_parameter_group.osha.id
  database_name                = "osha"
  master_username              = "mcp"
  master_password              = var.redshift_password
  node_type                    = "dc1.large"
  cluster_type                 = "single-node"
  cluster_subnet_group_name    = aws_redshift_subnet_group.osha.id
  publicly_accessible          = true
  encrypted                    = true
  enable_logging               = true
  enhanced_vpc_routing         = true
  bucket_name                  = data.terraform_remote_state.main.auditlogs
  s3_key_prefix                = "redshift/"

  vpc_security_group_ids = [
    aws_security_group.redshift_from_home.id,
    aws_security_group.all_outbound.id,
  ]

  tags = {
    project      = var.project
    description = "primary RedShift cluster"
    managed_by  = "Terraform"
  }

  iam_roles = [aws_iam_role.redshift_s3_reader.arn]
}

output "redshift_endpoint" {
  value = aws_redshift_cluster.osha_redshift.endpoint
}
*/

resource "aws_s3_bucket" "ml_bucket" {
  bucket        = "osha-ml"
  force_destroy = true

  /*
  logging {
    target_bucket = "${data.terraform_remote_state.main.auditlogs}"
    target_prefix = "s3logs/osha-ml/"
  }
*/

  tags = {
    Name       = "Staging location for AWS ML"
    project    = var.project
    managed_by = "Terraform"
  }
}
