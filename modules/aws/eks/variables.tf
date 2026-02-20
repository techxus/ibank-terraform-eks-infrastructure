############################################
# modules/aws/eks/variables.tf
# Purpose:
# - Define all inputs EKS needs
# Student notes:
# - The ENV folder sets values (terraform.tfvars)
# - The module declares what is allowed (variables.tf)
############################################

variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "dev, stage, prod"
  type        = string
}

variable "cluster_name_prefix" {
  description = "Prefix for cluster name (we add random suffix)"
  type        = string
  default     = "ibank"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

# Networking inputs come from the networking workspace
variable "vpc_id" {
  description = "VPC ID where EKS will live"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS worker nodes"
  type        = list(string)
}

# Endpoint flags (private-only cluster API)
variable "cluster_endpoint_public_access" {
  description = "If true, EKS API endpoint is reachable from the internet"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "If true, EKS API endpoint is reachable from inside the VPC"
  type        = bool
  default     = true
}

# Node sizing knobs
variable "node_instance_type" {
  description = "EC2 type for worker nodes (example: t3.small)"
  type        = string
  default     = "t3.small"
}

############################################
# Node group 1 sizing
############################################
variable "ng1_min_size" {
  description = "Node group 1: minimum number of nodes"
  type        = number
  default     = 1
}

variable "ng1_max_size" {
  description = "Node group 1: maximum number of nodes"
  type        = number
  default     = 3
}

variable "ng1_desired_size" {
  description = "Node group 1: desired number of nodes"
  type        = number
  default     = 2
}

############################################
# Node group 2 sizing
############################################
variable "ng2_min_size" {
  description = "Node group 2: minimum number of nodes"
  type        = number
  default     = 1
}

variable "ng2_max_size" {
  description = "Node group 2: maximum number of nodes"
  type        = number
  default     = 2
}

variable "ng2_desired_size" {
  description = "Node group 2: desired number of nodes"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}
