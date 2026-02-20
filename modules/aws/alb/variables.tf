############################################
# modules/aws/alb/variables.tf
# Purpose:
# - Inputs for AWS Load Balancer Controller install (IRSA + Helm)
############################################

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN (from EKS outputs)"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL (should be WITHOUT https:// for IRSA condition)"
  type        = string
}
