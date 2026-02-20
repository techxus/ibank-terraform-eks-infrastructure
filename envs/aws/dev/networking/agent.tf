############################################
# envs/aws/dev/networking/agent.tf
# Purpose:
# - Create an EC2 instance in a PRIVATE subnet to run the HCP Terraform Agent.
# - This solves: "private EKS endpoint unreachable from HCP runners".
#
# - Your EKS API endpoint is private-only => only reachable from inside the VPC.
# - HCP public runners live on the internet => cannot reach 10.x.x.x addresses.
# - The Agent runs inside your VPC and executes Terraform runs for you.
# - This makes "nuke + rebuild" fully automated with zero manual steps.
############################################

############################################
# Pick latest Amazon Linux 2023 AMI
############################################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

############################################
# Security group for the Agent EC2
# - No inbound needed (use SSM for access)
# - Outbound HTTPS needed (HCP + container image pulls)
############################################
resource "aws_security_group" "hcp_agent" {
  name        = "ibank-${var.env}-hcp-agent"
  description = "HCP Terraform Agent runner (private subnet, SSM-only)"
  vpc_id      = module.vpc.vpc_id

  # No ingress rules = nothing can connect inbound.
  # This is OK because we use AWS SSM Session Manager instead of SSH.

  egress {
    description = "Outbound HTTPS for HCP + package/image downloads"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.env
    Project     = "iBank"
  }
}

############################################
# IAM role so EC2 can be managed via SSM
# - This avoids SSH keys entirely.
############################################
data "aws_iam_policy_document" "ssm_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hcp_agent" {
  name               = "ibank-${var.env}-hcp-agent-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.hcp_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "hcp_agent" {
  name = "ibank-${var.env}-hcp-agent-profile"
  role = aws_iam_role.hcp_agent.name
}

############################################
# EC2 instance that runs the HCP Terraform Agent
############################################
resource "aws_instance" "hcp_agent" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro" # cheap and sufficient for Terraform runs
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.hcp_agent.id]
  iam_instance_profile   = aws_iam_instance_profile.hcp_agent.name

  ############################################
  # Production hardening defaults
  ############################################

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypt root disk
  root_block_device {
    encrypted = true
    volume_size = 20
    volume_type = "gp3"
  }

  ############################################
  # User data: install Docker and run the agent
  # IMPORTANT:
  # - We pass agent token as TF_VAR_hcp_agent_token from HCP (Sensitive).
  ############################################
  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker

    # Run HCP Terraform Agent container
    docker run -d --restart unless-stopped \
      --name hcp-terraform-agent \
      -e TFC_AGENT_TOKEN="${var.hcp_agent_token}" \
      hashicorp/tfc-agent:latest
  EOF

  tags = {
    Name        = "ibank-${var.env}-hcp-agent"
    Environment = var.env
    Project     = "iBank"
  }
}