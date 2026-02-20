output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
  description = "ARN of the IAM role created for the AWS Load Balancer Controller (used for IRSA)."
}
