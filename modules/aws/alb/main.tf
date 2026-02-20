############################################
# modules/aws/alb/main.tf
# Purpose:
# - Create IRSA role for AWS Load Balancer Controller
# - Install controller via Helm chart in kube-system namespace
#
# IMPORTANT:
# - This module expects the *caller* to configure AWS credentials.
# - This module expects the *caller* to configure Helm/Kubernetes providers.
############################################

locals {
  # IRSA typically wants the issuer without https://
  oidc_issuer_no_scheme = replace(var.oidc_provider_url, "https://", "")

  sa_namespace = "kube-system"
  sa_name      = "aws-load-balancer-controller"
}

############################################
# IRSA trust policy (service account -> IAM role)
############################################
data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_no_scheme}:sub"
      values   = ["system:serviceaccount:${local.sa_namespace}:${local.sa_name}"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}

############################################
# IAM permissions for the controller
#
# NOTE:
# AWS does NOT provide an AWS-managed policy ARN called
# AWSLoadBalancerControllerIAMPolicy by default.
#
# In production you create a customer-managed policy using the official JSON
# from AWS docs and attach it here.
############################################

# OPTION A (recommended): keep policy JSON in repo (fully automated)
# Create a file: modules/aws/alb/iam_policy.json
# and load it using file().
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

############################################
# Helm install
############################################
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = local.sa_namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  # Pin a known-good version (you can bump later intentionally)
  version = "1.7.2"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = var.vpc_id

      serviceAccount = {
        create = true
        name   = local.sa_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
        }
      }
    })
  ]
}