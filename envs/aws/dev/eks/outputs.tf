############################################
# envs/aws/dev/eks/outputs.tf
# Purpose:
# - Expose EKS outputs to students (and other stacks later)
############################################

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_oidc_provider_arn" {
  value = module.eks.cluster_oidc_provider_arn
}

output "cluster_oidc_provider" {
  value = module.eks.cluster_oidc_provider
}
