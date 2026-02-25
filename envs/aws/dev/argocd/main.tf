############################################################
# Read EKS Remote State
############################################################

data "terraform_remote_state" "eks" {
  backend = "remote"

  config = {
    organization = "softnet-hcp-labs"

    workspaces = {
      name = "ibank-aws-dev-eks"
    }
  }
}

############################################################
# Kubernetes Providers
############################################################

data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
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
# Namespace
############################################################

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

############################################################
# Install ArgoCD
############################################################

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.8"

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }

        ingress = {
          enabled = true
          ingressClassName = "alb"

          annotations = {
            "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"   = "ip"
            "alb.ingress.kubernetes.io/inbound-cidrs" = var.allowed_cidr
            "alb.ingress.kubernetes.io/listen-ports"  = "[{\"HTTP\":80}]"
          }

          hosts = ["argocd.dev.local"]
          paths = ["/"]
          pathType = "Prefix"
        }
      }

      configs = {
        secret = {
          argocdServerAdminPassword = bcrypt(var.argocd_admin_password)
        }
      }
    })
  ]
}