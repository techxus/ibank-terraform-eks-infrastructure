############################################
# modules/aws/eks/outputs.tf
# Purpose:
# - Export values other stacks need (IRSA, kubectl access, etc.)
############################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS control plane"
  value       = module.eks.cluster_security_group_id
}

############################################
# OIDC / IRSA outputs
############################################

output "oidc_provider" {
  description = "OIDC issuer URL for the cluster (includes https://)"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider (needed for IRSA)"
  value       = module.eks.oidc_provider_arn
}