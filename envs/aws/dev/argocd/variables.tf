variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "allowed_cidr" {
  description = "Your public IP in CIDR format"
  type        = string
}

variable "argocd_admin_password" {
  description = "Strong admin password"
  type        = string
  sensitive   = true
}