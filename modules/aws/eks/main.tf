############################################################
# modules/eks/main.tf
#
# - This module creates:
#   1) A VPC (all-private subnets)
#   2) An EKS cluster
#   3) Two managed node groups
#   4) EBS CSI driver add-on permissions using IRSA
#
# IMPORTANT:
# - Terraform does NOT run "files in order".
# - It builds a dependency graph and creates resources in the safe order.
############################################################

############################################################
# 1) AWS Provider
# This tells Terraform which AWS region to operate in.
############################################################
provider "aws" {
  region = var.config.region
}

############################################################
# 2) Availability Zones (AZs)
# We choose a number of AZs based on config.az_count.
############################################################
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

############################################################
# 3) Random suffix for uniqueness (helps avoid name collisions)
############################################################
resource "random_string" "suffix" {
  length  = 8
  special = false
}

############################################################
# 4) Locals (computed values)
############################################################
locals {
  # Cluster name becomes: ibank-dev-eks-1a2b3c4d
  cluster_name = "${var.config.name_prefix}-${var.config.env}-eks-${random_string.suffix.result}"

  # Pick first N AZs (N = az_count)
  azs = slice(data.aws_availability_zones.available.names, 0, var.config.az_count)

  ##########################################################
  # All-private subnets: generate 3 /24 subnets from VPC CIDR
  #
  # cidrsubnet(base, newbits, netnum)
  # - base = vpc_cidr (like 10.10.0.0/16)
  # - newbits=8 makes /24 networks
  # - netnum picks which /24 we want
  ##########################################################
  private_subnets = [
    cidrsubnet(var.config.vpc_cidr, 8, 1),
    cidrsubnet(var.config.vpc_cidr, 8, 2),
    cidrsubnet(var.config.vpc_cidr, 8, 3),
  ]

  # Common tags (helpful for cost tracking)
  tags = {
    Project     = var.config.project_tag
    Environment = var.config.env
  }
}

############################################################
# 5) VPC (all-private design) using terraform-aws-modules/vpc
############################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  # VPC name shown in AWS console
  name = "${var.config.name_prefix}-${var.config.env}-vpc"

  # VPC CIDR range
  cidr = var.config.vpc_cidr

  # Use chosen AZs
  azs = local.azs

  ##########################################################
  # All-private: only private subnets
  ##########################################################
  private_subnets = local.private_subnets

  ##########################################################
  # NAT Gateway:
  # Private subnets need outbound access to:
  # - pull container images
  # - reach AWS APIs
  #
  # enable_nat_gateway=true creates NAT.
  # single_nat_gateway=true makes it cheaper (but less HA).
  ##########################################################
  enable_nat_gateway = var.config.enable_nat_gateway
  single_nat_gateway = var.config.single_nat_gateway

  enable_dns_hostnames = true

  ##########################################################
  # Tag private subnets for INTERNAL load balancers
  ##########################################################
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

############################################################
# 6) EKS Cluster using terraform-aws-modules/eks
############################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = var.config.cluster_version

  ##########################################################
  # Private-only cluster API (recommended for prod)
  ##########################################################
  cluster_endpoint_public_access  = var.config.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.config.cluster_endpoint_private_access

  ##########################################################
  # For teaching: grants the creator admin access in Kubernetes.
  # In strict prod, you usually manage this via RBAC + IAM mapping.
  ##########################################################
  enable_cluster_creator_admin_permissions = true

  ##########################################################
  # Attach cluster to the VPC and private subnets
  ##########################################################
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  ##########################################################
  # EKS Add-ons: EBS CSI driver (persistent volumes on EBS)
  ##########################################################
  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa_ebs_csi.iam_role_arn
    }
  }

  ##########################################################
  # Managed node groups (two groups)
  ##########################################################
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name           = "${var.config.name_prefix}-${var.config.env}-ng-1"
      instance_types = [var.config.node_instance_type]

      min_size     = var.config.ng1_min
      max_size     = var.config.ng1_max
      desired_size = var.config.ng1_desired
    }

    two = {
      name           = "${var.config.name_prefix}-${var.config.env}-ng-2"
      instance_types = [var.config.node_instance_type]

      min_size     = var.config.ng2_min
      max_size     = var.config.ng2_max
      desired_size = var.config.ng2_desired
    }
  }

  tags = local.tags
}

############################################################
# 7) IRSA for EBS CSI driver (secure AWS permissions for pods)
############################################################

# AWS managed policy needed by the EBS CSI driver
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create an IAM role assumed by a Kubernetes service account via OIDC (IRSA)
module "irsa_ebs_csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role = true

  # Include env in the role name
  role_name = "${var.config.name_prefix}-${var.config.env}-EBSCSIRole-${module.eks.cluster_name}"

  # OIDC provider URL from the EKS cluster
  provider_url = module.eks.oidc_provider

  # Attach the managed policy
  role_policy_arns = [data.aws_iam_policy.ebs_csi_policy.arn]

  # Only this service account can assume the role
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:ebs-csi-controller-sa"
  ]

  tags = local.tags
}
