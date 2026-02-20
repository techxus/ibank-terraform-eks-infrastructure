############################################
# envs/aws/dev/eks/outputs.tf
# Purpose:
# - Show useful outputs (students + future stacks).
############################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN (for IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC issuer URL (for IRSA)"
  value       = module.eks.oidc_provider
}

output "alb_controller_role_arn" {
  description = "IAM Role ARN used by AWS Load Balancer Controller (IRSA)"
  value       = aws_iam_role.alb_controller.arn
}