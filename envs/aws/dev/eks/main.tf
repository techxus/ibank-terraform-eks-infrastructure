############################################################
# DEV EKS Environment Stack
#
# Responsibilities:
# 1) Read networking remote state
# 2) Create EKS cluster
# 3) Configure Kubernetes + Helm providers
# 4) Install AWS Load Balancer Controller (production IRSA)
############################################################

############################################################
# 1. Read Networking Workspace State
############################################################

data "terraform_remote_state" "networking" {
  backend = "remote"

  config = {
    organization = "softnet-hcp-labs"

    workspaces = {
      name = "ibank-aws-dev-networking"
    }
  }
}

############################################################
# 2. Create EKS Cluster
############################################################

module "eks" {
  source = "../../../../modules/aws/eks"

  region = var.region
  env    = var.env

  cluster_name_prefix = var.cluster_name_prefix
  cluster_version     = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  node_instance_type = var.node_instance_type

  ng1_min_size     = var.ng1_min_size
  ng1_max_size     = var.ng1_max_size
  ng1_desired_size = var.ng1_desired_size

  ng2_min_size     = var.ng2_min_size
  ng2_max_size     = var.ng2_max_size
  ng2_desired_size = var.ng2_desired_size

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
    Project     = "iBank"
  }
}

############################################################
# 3. Configure Kubernetes + Helm Providers
############################################################

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}

############################################################
# 4. Install AWS Load Balancer Controller (Production)
############################################################

module "alb_controller" {
  source = "../../../../modules/aws/alb"

  providers = {
    aws        = aws
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name      = module.eks.cluster_name
  region            = var.region
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
}