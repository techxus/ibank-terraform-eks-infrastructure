############################################
# modules/aws/eks/main.tf
# Purpose:
# - Create an EKS cluster and managed node groups (AWS resources only).
#
# Student notes:
# - Modules should NOT define provider blocks inside them in modern Terraform.
# - Providers are configured in the ROOT (env) folder and passed in automatically.
############################################

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  # Cluster name is stable and environment-specific
  # NOTE: If you want uniqueness, add suffix back in:
  # cluster_name = "${var.cluster_name_prefix}-${var.env}-eks-${random_string.suffix.result}"
  cluster_name = "${var.cluster_name_prefix}-${var.env}-eks"

  common_tags = merge(
    {
      Environment = var.env
      ManagedBy   = "Terraform"
      Project     = "iBank EKS Infrastructure Project"
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

  # OK for labs; in strict enterprises you manage access more tightly
  enable_cluster_creator_admin_permissions = true

  # Attach cluster to existing VPC
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Node group defaults
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  # Two managed node groups
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

  access_entries = {
    hcp_agent = {
      principal_arn = var.hcp_agent_role_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = local.common_tags
}

############################################
# Providers for talking to the EKS cluster
# Purpose:
# - Helm install of ALB controller happens in the ROOT stack.
#
# Student notes:
# - This works because HCP runs via Agent inside the VPC.
############################################

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}