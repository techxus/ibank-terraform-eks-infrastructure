############################################
# modules/aws/alb/outputs.tf
# Purpose:
# - Export the IRSA role ARN (useful for debugging/auditing)
############################################

output "alb_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}
