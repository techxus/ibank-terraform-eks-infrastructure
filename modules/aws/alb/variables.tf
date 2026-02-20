############################################
# modules/aws/alb/variables.tf
# Purpose:
# - Inputs required to install AWS Load Balancer Controller
# Notes:
# - This module NEVER references module.eks.*
# - The env root passes in EKS outputs as variables
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
  description = "VPC ID where EKS runs"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the cluster (IRSA)"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL for the cluster (can be with or without https://)"
  type        = string
}