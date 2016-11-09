variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "172.33.0.0/16"
}

variable "vpc_name" {
  description = "Name for the VPC"
  default     = "osha_redshift"
}

variable "home_ip" {
  description = "Home IP address from which SSH is permitted"
  default     = "75.172.105.6"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "redshift_password" {
  description = "Master password for RedShift cluster."
}
