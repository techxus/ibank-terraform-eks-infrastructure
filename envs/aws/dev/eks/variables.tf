############################################
# envs/aws/dev/eks/variables.tf
#
# STUDENT NOTES:
# - This folder (envs/aws/dev/eks) is a "root module".
# - HCP Terraform runs this folder.
# - This file declares which INPUTS this environment accepts.
# - The actual values are set in terraform.tfvars (in the same folder).
#
# IMPORTANT HCL RULE:
# - If a variable has more than ONE property (type, default, description),
#   you MUST use multi-line syntax like below.
############################################

variable "region" {
  description = "AWS region for DEV (example: us-east-1)"
  type        = string
}

variable "env" {
  description = "Environment name. Here it must be 'dev'."
  type        = string
}

variable "cluster_name_prefix" {
  description = "Prefix for naming the EKS cluster"
  type        = string
  default     = "ibank"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_public_access" {
  description = "If true, EKS API is reachable from the public internet (NOT recommended)"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "If true, EKS API is reachable only inside the VPC (recommended)"
  type        = bool
  default     = true
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.small"
}

############################################
# Node group 1 sizing
############################################
variable "ng1_min_size" {
  description = "Node group 1: minimum nodes"
  type        = number
  default     = 1
}

variable "ng1_max_size" {
  description = "Node group 1: maximum nodes"
  type        = number
  default     = 2
}

variable "ng1_desired_size" {
  description = "Node group 1: desired nodes"
  type        = number
  default     = 1
}

############################################
# Node group 2 sizing
############################################
variable "ng2_min_size" {
  description = "Node group 2: minimum nodes"
  type        = number
  default     = 1
}

variable "ng2_max_size" {
  description = "Node group 2: maximum nodes"
  type        = number
  default     = 2
}

variable "ng2_desired_size" {
  description = "Node group 2: desired nodes"
  type        = number
  default     = 1
}
