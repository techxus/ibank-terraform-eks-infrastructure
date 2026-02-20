############################################
# envs/aws/dev/networking/outputs.tf
# Purpose:
# - Re-export module outputs at the root level
# - So other workspaces (EKS) can read them via terraform_remote_state
############################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
