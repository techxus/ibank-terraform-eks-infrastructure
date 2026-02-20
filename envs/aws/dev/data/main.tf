############################################
# envs/aws/dev/data/main.tf
# Purpose:
# - Later: create RDS/MSK/ElastiCache in DEV
# - Keep this separate so EKS can be destroyed without touching databases
############################################

# For now, we leave it empty on purpose.
# When you're ready, we will:
# - read networking remote state (vpc_id + subnets)
# - create RDS / MSK / Elasticache modules here
