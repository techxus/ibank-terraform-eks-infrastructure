output "alb_controller_role_arn" {
  value       = aws_iam_role.this.arn
  description = "IRSA role ARN for AWS Load Balancer Controller"
}

output "alb_controller_policy_arn" {
  value       = aws_iam_policy.this.arn
  description = "IAM policy ARN attached to the controller role"
}