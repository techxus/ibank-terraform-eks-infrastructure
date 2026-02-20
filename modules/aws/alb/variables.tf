############################################
# Inputs required for ALB Controller
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
  description = "VPC ID where ALBs will be created"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN from EKS"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL from EKS"
  type        = string
}
