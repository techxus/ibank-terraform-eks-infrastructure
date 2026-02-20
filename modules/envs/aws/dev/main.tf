############################################################
# envs/dev/main.tf
#
# - This is the "launcher" for DEV.
# - It calls the reusable module and passes the config object.
############################################################

module "eks" {
  source = "../../modules/eks"

  # Pass the whole config object into the module
  config = var.config
}
