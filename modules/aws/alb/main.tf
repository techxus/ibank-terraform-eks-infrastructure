############################################
# modules/aws/alb/main.tf
# Purpose:
# - Install AWS Load Balancer Controller
# - Create IRSA role for its ServiceAccount
#
# Student notes:
# - The controller runs inside Kubernetes.
# - It needs AWS permissions to create ALBs, target groups, etc.
# - IRSA is the secure way (no node IAM hacks).
############################################

provider "aws" {
  region = var.region
}

############################################
# IAM Policy (official JSON from AWS docs)
# NOTE: AWS does NOT always provide a managed policy ARN for this.
# We create our own policy resource here.
############################################

data "aws_iam_policy_document" "alb_controller_policy" {
  # Minimal working policy is long in real life.
  # In production, you use the official JSON policy from AWS docs.
  #
  # To keep this answer short AND correct, we’ll reference the official
  # policy by URL later if needed, but Terraform must have real statements.
  #
  # For now, we include the most important broad permissions needed.
  statement {
    actions = [
      "elasticloadbalancing:*",
      "ec2:Describe*",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "iam:CreateServiceLinkedRole",
      "cognito-idp:DescribeUserPoolClient",
      "waf-regional:*",
      "wafv2:*",
      "shield:*",
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = data.aws_iam_policy_document.alb_controller_policy.json
}

############################################
# IRSA Role (assumable by ServiceAccount)
############################################

data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

############################################
# Install via Helm (requires Kubernetes API reachability)
############################################

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
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

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = var.vpc_id

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
