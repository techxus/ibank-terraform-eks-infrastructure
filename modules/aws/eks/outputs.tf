############################################
# outputs.tf
# Purpose: print useful values after apply
############################################

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane" # what this output represents
  value       = module.eks.cluster_endpoint      # actual value from the EKS module
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}
