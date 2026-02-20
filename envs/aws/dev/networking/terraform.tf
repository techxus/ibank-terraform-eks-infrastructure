########################################################################################
# envs/aws/dev/networking/terraform.tf
# Purpose:
# - This folder is a "root module"
# - HCP Terraform runs THIS folder and stores state for DEV networking
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
