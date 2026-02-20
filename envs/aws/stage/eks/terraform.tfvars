############################################################
# envs/stage/terraform.tfvars
# Stage is closer to prod but still moderate.
############################################################

config = {
  region = "us-east-1"
  env    = "stage"

  vpc_cidr = "10.20.0.0/16"
  az_count = 3

  enable_nat_gateway = true
  single_nat_gateway = true

  name_prefix = "ibank"
  project_tag = "iBank EKS"

  # Stage often matches prod version
  cluster_version = "1.29"

  # Keep private-only for security consistency
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  node_instance_type = "t3.medium"

  ng1_min     = 1
  ng1_max     = 4
  ng1_desired = 3

  ng2_min     = 1
  ng2_max     = 3
  ng2_desired = 2
}
