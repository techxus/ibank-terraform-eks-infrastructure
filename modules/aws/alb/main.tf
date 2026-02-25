locals {
  # Ensure we always use issuer WITHOUT https:// in the trust policy condition key
  oidc_issuer_hostpath = replace(var.oidc_provider_url, "https://", "")
  role_name            = "${var.cluster_name}-aws-lbc"
  policy_name          = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Official controller IAM policy JSON (vendor it in Terraform so rebuilds are deterministic)
# Source: kubernetes-sigs/aws-load-balancer-controller v3.1.0
resource "aws_iam_policy" "this" {
  name   = local.policy_name
  policy = <<POLICY
{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": [ "iam:CreateServiceLinkedRole" ], "Resource": "*", "Condition": { "StringEquals": { "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com" } } }, { "Effect": "Allow", "Action": [ "ec2:DescribeAccountAttributes", "ec2:DescribeAddresses", "ec2:DescribeAvailabilityZones", "ec2:DescribeInternetGateways", "ec2:DescribeVpcs", "ec2:DescribeVpcPeeringConnections", "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups", "ec2:DescribeInstances", "ec2:DescribeNetworkInterfaces", "ec2:DescribeTags", "ec2:GetCoipPoolUsage", "ec2:DescribeCoipPools", "ec2:GetSecurityGroupsForVpc", "ec2:DescribeIpamPools", "ec2:DescribeRouteTables", "elasticloadbalancing:DescribeLoadBalancers", "elasticloadbalancing:DescribeLoadBalancerAttributes", "elasticloadbalancing:DescribeListeners", "elasticloadbalancing:DescribeListenerCertificates", "elasticloadbalancing:DescribeSSLPolicies", "elasticloadbalancing:DescribeRules", "elasticloadbalancing:DescribeTargetGroups", "elasticloadbalancing:DescribeTargetGroupAttributes", "elasticloadbalancing:DescribeTargetHealth", "elasticloadbalancing:DescribeTags", "elasticloadbalancing:DescribeTrustStores", "elasticloadbalancing:DescribeListenerAttributes", "elasticloadbalancing:DescribeCapacityReservation" ], "Resource": "*" }, { "Effect": "Allow", "Action": [ "cognito-idp:DescribeUserPoolClient", "acm:ListCertificates", "acm:DescribeCertificate", "iam:ListServerCertificates", "iam:GetServerCertificate", "waf-regional:GetWebACL", "waf-regional:GetWebACLForResource", "waf-regional:AssociateWebACL", "waf-regional:DisassociateWebACL", "wafv2:GetWebACL", "wafv2:GetWebACLForResource", "wafv2:AssociateWebACL", "wafv2:DisassociateWebACL", "shield:GetSubscriptionState", "shield:DescribeProtection", "shield:CreateProtection", "shield:DeleteProtection" ], "Resource": "*" }, { "Effect": "Allow", "Action": [ "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress" ], "Resource": "*" }, { "Effect": "Allow", "Action": [ "ec2:CreateSecurityGroup" ], "Resource": "*" }, { "Effect": "Allow", "Action": [ "ec2:CreateTags" ], "Resource": "arn:aws:ec2:*:*:security-group/*", "Condition": { "StringEquals": { "ec2:CreateAction": "CreateSecurityGroup" }, "Null": { "aws:RequestTag/elbv2.k8s.aws/cluster": "false" } } }, { "Effect": "Allow", "Action": [ "ec2:CreateTags", "ec2:DeleteTags" ], "Resource": "arn:aws:ec2:*:*:security-group/*", "Condition": { "Null": { "aws:RequestTag/elbv2.k8s.aws/cluster": "true", "aws:ResourceTag/elbv2.k8s.aws/cluster": "false" } } }, { "Effect": "Allow", "Action": [ "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress", "ec2:DeleteSecurityGroup" ], "Resource": "*", "Condition": { "Null": { "aws:ResourceTag/elbv2.k8s.aws/cluster": "false" } } }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:CreateTargetGroup" ], "Resource": "*", "Condition": { "Null": { "aws:RequestTag/elbv2.k8s.aws/cluster": "false" } } }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:CreateListener", "elasticloadbalancing:DeleteListener", "elasticloadbalancing:CreateRule", "elasticloadbalancing:DeleteRule" ], "Resource": "*" }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags" ], "Resource": [ "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*", "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*", "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*" ], "Condition": { "Null": { "aws:RequestTag/elbv2.k8s.aws/cluster": "true", "aws:ResourceTag/elbv2.k8s.aws/cluster": "false" } } }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags" ], "Resource": [ "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*", "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*", "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*", "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*" ] }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:ModifyLoadBalancerAttributes", "elasticloadbalancing:SetIpAddressType", "elasticloadbalancing:SetSecurityGroups", "elasticloadbalancing:SetSubnets", "elasticloadbalancing:DeleteLoadBalancer", "elasticloadbalancing:ModifyTargetGroup", "elasticloadbalancing:ModifyTargetGroupAttributes", "elasticloadbalancing:DeleteTargetGroup", "elasticloadbalancing:ModifyListenerAttributes", "elasticloadbalancing:ModifyCapacityReservation", "elasticloadbalancing:ModifyIpPools" ], "Resource": "*", "Condition": { "Null": { "aws:ResourceTag/elbv2.k8s.aws/cluster": "false" } } }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:AddTags" ], "Resource": [ "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*", "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*", "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*" ], "Condition": { "StringEquals": { "elasticloadbalancing:CreateAction": [ "CreateTargetGroup", "CreateLoadBalancer" ] }, "Null": { "aws:RequestTag/elbv2.k8s.aws/cluster": "false" } } }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets" ], "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*" }, { "Effect": "Allow", "Action": [ "elasticloadbalancing:SetWebAcl", "elasticloadbalancing:ModifyListener", "elasticloadbalancing:AddListenerCertificates", "elasticloadbalancing:RemoveListenerCertificates", "elasticloadbalancing:ModifyRule", "elasticloadbalancing:SetRulePriorities" ], "Resource": "*" } ] }
POLICY
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "helm_release" "this" {
  name       = "aws-load-balancer-controller"
  namespace  = var.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = var.vpc_id

      image = {
        tag = var.image_tag
      }

      serviceAccount = {
        create = true
        name   = var.service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
        }
      }
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.this]
}