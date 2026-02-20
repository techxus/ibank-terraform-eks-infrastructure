############################################
# modules/aws/eks/main.tf
# Purpose:
# - Create EKS cluster + 2 managed node groups
# - Private-only EKS API endpoint (recommended)
#
# Student notes:
# - "module eks" below is a popular open-source module maintained by the community.
# - We pass it inputs like vpc_id and subnet_ids to attach it to our VPC.
############################################

provider "aws" {
  region = var.region
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  # Make cluster name unique so multiple students can run it without collisions
  cluster_name = "${var.cluster_name_prefix}-${var.env}-eks-${random_string.suffix.result}"

  common_tags = merge(
    {
      Environment = var.env
      ManagedBy   = "Terraform"
      Project     = "iBank"
    },
    var.tags
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  # Private-only endpoint (production-grade)
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # Helpful for labs; in strict enterprises you manage access more tightly
  enable_cluster_creator_admin_permissions = true

  # Attach cluster to existing VPC
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Defaults for node groups
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  # Two node groups (good for teaching scaling + separation)
  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = [var.node_instance_type]

      min_size     = var.ng1_min_size
      max_size     = var.ng1_max_size
      desired_size = var.ng1_desired_size
    }

    two = {
      name           = "node-group-2"
      instance_types = [var.node_instance_type]

      min_size     = var.ng2_min_size
      max_size     = var.ng2_max_size
      desired_size = var.ng2_desired_size
    }
  }

  tags = local.common_tags
}
