terraform {
  required_version = ">= 1.4.0"

  backend "remote" {
    organization = "softnet-hcp-labs"

    workspaces {
      name = "ibank-aws-dev-argocd"
    }
  }
}