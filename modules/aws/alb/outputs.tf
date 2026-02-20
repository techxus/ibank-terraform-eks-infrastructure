############################################
# modules/aws/alb/outputs.tf
############################################

output "alb_controller_role_arn" {
  value       = aws_iam_role.alb_controller.arn
  description = "ARN of the IAM role created for AWS Load Balancer Controller (IRSA)"
}