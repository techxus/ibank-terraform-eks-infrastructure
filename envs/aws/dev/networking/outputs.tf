############################################
# envs/aws/dev/networking/outputs.tf
# Purpose:
# - Re-export module outputs at the root level
# - So other workspaces (EKS) can read them via terraform_remote_state
############################################

output "vpc_id" {
  description = "VPC ID for the environment"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
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
