############################################################
# envs/stage/main.tf
# Same launcher as dev; stage differences are in terraform.tfvars
############################################################

module "eks" {
  source = "../../../../modules/aws/eks"
  config = var.config
}
