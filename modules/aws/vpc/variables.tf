############################################
# modules/aws/vpc/variables.tf
# Purpose:
# - Declare inputs for the VPC module
#
# Student notes:
# - "variables.tf" defines what inputs are allowed.
# - Values come from env terraform.tfvars.
############################################

variable "region" {
  description = "AWS region (example: us-east-1)"
  type        = string
}

variable "env" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR range (example: 10.10.0.0/16)"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use (2 or 3 are common)"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "If true, create 1 NAT Gateway to reduce cost (less HA)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags for AWS resources"
  type        = map(string)
  default     = {}
}
