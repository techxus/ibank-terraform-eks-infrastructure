########################################################################################
# modules/aws/eks/outputs.tf
# Purpose:
# - Expose cluster details to the env folder (and to students)
#########################################################################################

########################################################################################
# Reference Documentation:
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest?tab=outputs
########################################################################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "EKS control plane security group"
  value       = module.eks.cluster_security_group_id
}

# These two are the ones you need for IRSA
output "oidc_provider_arn" {
  description = "OIDC provider ARN (IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "OIDC provider URL (IRSA). Often without https://"
  value       = module.eks.oidc_provider
}