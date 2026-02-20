############################################################
# envs/prod/main.tf
# Same launcher as dev/stage; prod differences are in terraform.tfvars
############################################################

module "eks" {
  source = "../../modules/eks"
  config = var.config
}
