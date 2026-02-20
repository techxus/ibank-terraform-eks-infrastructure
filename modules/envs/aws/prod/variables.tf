############################################################
# envs/prod/variables.tf
# Same schema as dev/stage.
############################################################

variable "config" {
  description = "PROD environment config object"
  type = object({
    region = string
    env    = string

    vpc_cidr = string
    az_count = number

    enable_nat_gateway = bool
    single_nat_gateway = bool

    name_prefix = string
    project_tag = string

    cluster_version = string

    cluster_endpoint_public_access  = bool
    cluster_endpoint_private_access = bool

    node_instance_type = string

    ng1_min     = number
    ng1_max     = number
    ng1_desired = number

    ng2_min     = number
    ng2_max     = number
    ng2_desired = number
  })
}
