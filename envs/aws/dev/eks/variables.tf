############################################
# envs/aws/dev/eks/variables.tf
# Purpose:
# - Root vars for the EKS stack
############################################

variable "region" { type = string }
variable "env"    { type = string }

variable "cluster_name_prefix" { type = string, default = "ibank" }
variable "cluster_version"     { type = string, default = "1.29" }

variable "cluster_endpoint_public_access"  { type = bool, default = false }
variable "cluster_endpoint_private_access" { type = bool, default = true }

variable "node_instance_type" { type = string, default = "t3.small" }

variable "ng1_min_size"     { type = number, default = 1 }
variable "ng1_max_size"     { type = number, default = 3 }
variable "ng1_desired_size" { type = number, default = 2 }

variable "ng2_min_size"     { type = number, default = 1 }
variable "ng2_max_size"     { type = number, default = 2 }
variable "ng2_desired_size" { type = number, default = 1 }
