############################################
# envs/aws/dev/networking/variables.tf
# Purpose:
# - Root modules MUST declare variables they use
# - terraform.tfvars provides the values
############################################

variable "region"   { type = string }
variable "env"      { type = string }
variable "vpc_name" { type = string }
variable "vpc_cidr" { type = string }

variable "az_count" {
  type    = number
  default = 3
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

