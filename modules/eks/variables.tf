############################################################
# modules/eks/variables.tf
#
# - A "module" is a reusable blueprint.
# - This module builds VPC + EKS.
# - We accept ONE input called "config" (an object).
# - This avoids declaring 20 separate variables in many places.
############################################################

variable "config" {
  description = "All environment settings (dev/stage/prod) passed as one object"
  type = object({
    ########################################################
    # Basic identity
    ########################################################
    region = string       # AWS region, ex: "us-east-1"
    env    = string       # environment name, ex: "dev"

    ########################################################
    # Networking (VPC)
    ########################################################
    vpc_cidr = string     # ex: "10.10.0.0/16"
    az_count = number     # how many AZs to use (2 or 3 typical)

    enable_nat_gateway = bool # NAT allows private subnets to reach internet outbound
    single_nat_gateway = bool # true=cheaper, false=more HA

    ########################################################
    # Naming & tagging
    ########################################################
    name_prefix = string  # ex: "ibank"
    project_tag = string  # ex: "iBank EKS"

    ########################################################
    # EKS control plane
    ########################################################
    cluster_version = string # ex: "1.29"

    # Private-only cluster API is most secure (prod standard)
    cluster_endpoint_public_access  = bool
    cluster_endpoint_private_access = bool

    ########################################################
    # Node groups (2 groups, like your original tutorial)
    ########################################################
    node_instance_type = string # ex: "t3.small", "m6i.large"

    # Node group 1 sizing
    ng1_min     = number
    ng1_max     = number
    ng1_desired = number

    # Node group 2 sizing
    ng2_min     = number
    ng2_max     = number
    ng2_desired = number
  })
}
