############################################
# envs/aws/dev/networking/outputs.tf
# Purpose:
# - Re-export module outputs at the root level
# - So other workspaces (EKS) can read them via terraform_remote_state
############################################

output "vpc_id" {
  description = "VPC ID for this environment"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for this environment"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

############################################
# Agent outputs (useful for debugging / SSM access)
############################################
output "hcp_agent_instance_id" {
  description = "EC2 instance id for the HCP Terraform Agent"
  value       = aws_instance.hcp_agent.id
}

output "hcp_agent_private_ip" {
  description = "Private IP of the agent instance"
  value       = aws_instance.hcp_agent.private_ip
}

output "hcp_agent_role_arn" {
  description = "IAM role ARN assumed by the HCP Agent EC2 instance (for EKS access entries)"
  value       = aws_iam_role.hcp_agent.arn
}