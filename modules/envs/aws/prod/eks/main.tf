############################################################
# envs/prod/main.tf
# Same launcher as dev/stage; prod differences are in terraform.tfvars
############################################################

module "eks" {
  source = "../../../../modules/aws/eks"
  config = var.config
}
