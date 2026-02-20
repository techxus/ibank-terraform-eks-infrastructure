############################################
# modules/aws/eks/outputs.tf
# Purpose:
# - Expose values other stacks need (like ALB Controller IRSA)
############################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS control plane endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS control plane"
  value       = module.eks.cluster_security_group_id
}


output "oidc_provider_arn"  {
  value = module.eks.oidc_provider_arn
  description = "ARN of the OIDC provider created for the EKS cluster. This is needed for IRSA (IAM Roles for Service Accounts) to work, and is used by the ALB Controller module to create an IAM role for the controller's service account."
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
  description = "URL of the OIDC issuer for the EKS cluster. This is needed for IRSA (IAM Roles for Service Accounts) to work, and is used by the ALB Controller module to create an IAM role for the controller's service account. Note that some IRSA modules expect this URL without the 'https://' prefix, so you may need to use the 'replace' function when passing this output to those modules."
}

