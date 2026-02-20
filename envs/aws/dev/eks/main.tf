############################################
# envs/aws/dev/eks/main.tf
# Purpose:
# - Read networking outputs from networking workspace (remote state)
# - Create EKS (AWS resources)
# - Install AWS Load Balancer Controller (in-cluster) via Helm
#
# Student notes:
# - "terraform_remote_state" reads outputs from another Terraform state safely.
# - Providers (aws/kubernetes/helm) are configured in THIS root module.
############################################

############################################
# 1) Read networking outputs from HCP workspace
############################################
data "terraform_remote_state" "networking" {
  backend = "remote"

  config = {
    organization = "softnet-hcp-labs"
    workspaces = {
      name = "ibank-aws-dev-networking"
    }
  }
}

############################################
# 2) Create EKS (using your local wrapper module that calls official EKS module)
############################################
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
}

############################################
# 3) Configure Kubernetes + Helm providers for PRIVATE EKS
# (This works because your run executes via the Agent inside the VPC.)
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

############################################
# 4) Create IAM role for IRSA (ALB controller)
# Student notes:
# - IRSA lets a Kubernetes ServiceAccount assume an AWS IAM role.
############################################
data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${module.eks.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}

# NOTE:
# AWS documents installing the controller with IAM permissions.
# Many teams attach the official controller policy JSON themselves.
# The AWS docs describe the Helm install flow. :contentReference[oaicite:2]{index=2}
#
# If your account has the AWS-managed policy shown below, this works.
# If not, we will create the policy from the official JSON next.
resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

############################################
# 5) Install AWS Load Balancer Controller via Helm
# Student notes:
# - The controller will create ALBs when you create Kubernetes Ingress objects.
############################################
resource "helm_release" "aws_load_balancer_controller" {
  count      = var.install_cluster_addons ? 1 : 0
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  # Pin chart version (production practice)
  version = "1.7.2"

  values = [
    yamlencode({
      clusterName = module.eks.cluster_name
      region      = var.region
      vpcId       = data.terraform_remote_state.networking.outputs.vpc_id

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
        }
      }
    })
  ]
}