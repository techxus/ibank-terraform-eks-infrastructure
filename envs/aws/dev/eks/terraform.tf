########################################################################################
# envs/aws/dev/eks/terraform.tf
# Purpose:
# - Root module for DEV EKS
########################################################################################

########################################################################################
# Reference Documentation:
# https://registry.terraform.io/providers/hashicorp/aws/latest
########################################################################################

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47"
    }
  }
}
