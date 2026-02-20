############################################
# modules/aws/vpc/variables.tf
# Purpose:
# - Define the INPUTS this module expects.
# - These are "knobs" that envs (dev/stage/prod) can set.
############################################
variable "region" {
  description = "AWS region where we create the VPC"
  type        = string
}

variable "env" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The VPC CIDR block (example: 10.0.0.0/16)"
  type        = string
}

variable "az_count" {
  description = "How many Availability Zones to spread across (usually 2 or 3)"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "If true, create ONE NAT Gateway (cheaper). If false, one per AZ (more resilient, more expensive)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra AWS tags for all resources"
  type        = map(string)
  default     = {}
}
