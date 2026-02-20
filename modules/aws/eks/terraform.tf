############################################
# terraform.tf
# Purpose: Terraform "global" settings:
# - required Terraform version
# - required provider plugins + versions
# - (optional) Terraform Cloud/HCP "cloud" block (commented out here)
############################################

terraform {
  # The "cloud" block is one way to tell Terraform CLI to use HCP Terraform.
  # In your setup, HCP Terraform is already running via the UI + VCS workflow,
  # so this block is not needed and is commented out.
  #
  # cloud {
  #   workspaces {
  #     name = "learn-terraform-eks"
  #   }
  # }

  # Providers are plugins Terraform downloads and uses to talk to APIs.
  # Pinning versions makes builds reproducible for a team.
  required_providers {
    # AWS provider: creates VPC, EKS, IAM, etc.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0" # "~>" means allow patch/minor updates, keep within 5.x
    }

    # Random provider: generates random values (used for random cluster suffix)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }

    # TLS provider: not used in the files you pasted, but available if needed.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }

    # Cloud-init provider: not used in the files you pasted, but available if needed.
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
  }

  # Enforces Terraform version compatibility in the runtime that executes this code.
  required_version = "~> 1.3"
}
