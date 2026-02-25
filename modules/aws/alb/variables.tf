variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS runs"
}

variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC provider ARN (for IRSA)"
}

variable "oidc_provider_url" {
  type        = string
  description = "EKS OIDC issuer URL (either with or without https://; we normalize it)"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace to install the controller"
}

variable "service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "ServiceAccount name for the controller"
}

variable "chart_version" {
  type        = string
  default     = "3.0.0"
  description = "Helm chart version from aws/eks-charts"
}

variable "image_tag" {
  type        = string
  default     = "v3.1.0"
  description = "Controller image tag"
}