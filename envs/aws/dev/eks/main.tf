############################################
# envs/aws/dev/eks/main.tf
# Purpose:
# - Read networking outputs from the DEV networking workspace state
# - Create EKS using those VPC/subnets
#
# Student notes:
# - "terraform_remote_state" reads outputs from ANOTHER Terraform state.
# - This is how we connect stacks safely without copying/pasting IDs.
############################################

# Read outputs from the DEV networking workspace
data "terraform_remote_state" "networking" {
  backend = "remote"

  config = {
    organization = "softnet-hcp-labs"

    workspaces = {
      # IMPORTANT: you must create this workspace in HCP
      name = "ibank-aws-dev-networking"
    }
  }
}

module "eks" {
  source = "../../../../modules/aws/eks"

  region = var.region
  env    = var.env

  cluster_name_prefix = var.cluster_name_prefix
  cluster_version     = var.cluster_version

  # Private-only EKS endpoint flags
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # VPC wiring from networking stack
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  # Node sizing knobs
  node_instance_type = var.node_instance_type

  ng1_min_size     = var.ng1_min_size
  ng1_max_size     = var.ng1_max_size
  ng1_desired_size = var.ng1_desired_size

  ng2_min_size     = var.ng2_min_size
  ng2_max_size     = var.ng2_max_size
  ng2_desired_size = var.ng2_desired_size

  tags = {
    Owner = "PlatformTeam"
  }
}

########################################################################################
# Install AWS Load Balancer Controller
########################################################################################
module "alb_controller" {
  source = "../../../../modules/aws/alb"

  cluster_name = module.eks.cluster_name
  region       = var.region
  vpc_id       = data.terraform_remote_state.networking.outputs.vpc_id

  oidc_provider_arn = module.eks.oidc_provider_arn

  # Normalize to "no https://" for IRSA condition
  oidc_provider_url = replace(module.eks.oidc_provider, "https://", "")
}


