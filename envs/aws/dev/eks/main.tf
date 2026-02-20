########################################################################################
# AWS Load Balancer Controller (ALBC) - Production install
#
# Purpose:
# - Allows Kubernetes Ingress resources to create/manage AWS ALBs automatically.
# - Required for production-grade HTTP/HTTPS ingress on EKS.
#
# Why here (env) and not in modules/aws/eks?
# - EKS module should focus on EKS itself.
# - Add-ons are "cluster software" installed *into* Kubernetes, so they live in the
#   environment stack where we already have cluster context and ordering.
########################################################################################

############################################
# IRSA trust policy: ONLY this ServiceAccount can assume the IAM role
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

      # OIDC issuer without https:// is required here
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }
  }
}

############################################
# IAM Role for ALBC (IRSA)
############################################
resource "aws_iam_role" "alb_controller" {
  name               = "${module.eks.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}

############################################
# Attach permissions policy
#
# NOTE:
# - If your account does not have this managed policy, apply will fail.
# - If that happens, tell me and I’ll give you the official AWS policy JSON
#   as code (aws_iam_policy) + attachment (still no manual steps).
############################################
resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

############################################
# Install ALBC using Helm
############################################
resource "helm_release" "aws_load_balancer_controller" {
  count      = var.install_cluster_addons ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  # Pin version for production stability
  version    = "1.7.2"

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

module "alb_controller" {
  source = "../../../../modules/aws/alb"

  cluster_name      = module.eks.cluster_name
  region            = var.region
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider
}