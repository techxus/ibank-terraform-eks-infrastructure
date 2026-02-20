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
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS control plane"
  value       = module.eks.cluster_security_group_id
}
