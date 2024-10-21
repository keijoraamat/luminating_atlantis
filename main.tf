data "aws_caller_identity" "current" {}

locals {
  tags = {
    application = var.app_name
  }

  # Split the ARN into parts
  arn_parts = split("/", data.aws_caller_identity.current.arn)

  # Get the last part of the ARN, which is the username or role name
  caller_name = local.arn_parts[length(local.arn_parts) - 1]

  # Determine if the caller is a user or a role based on the ARN format
  is_user = length(regexall(":user/", data.aws_caller_identity.current.arn)) > 0

  caller_arn = data.aws_caller_identity.current.arn
}

# Create a VPC with one public and one private subnet
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = "${var.app_name}-vpc"
  cidr = var.vpc_cidr_block

  azs             = ["us-east-1a", "us-east-1b"] # Single availability zone
  private_subnets = var.private_subnets_cidr_blocks
  public_subnets  = var.public_subnets_cidr_blocks

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Single NAT gateway for internet access from the private subnet
  single_nat_gateway = true
  enable_nat_gateway = true

  tags = local.tags
}

# Create EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-cluster"
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access_cidrs = var.public_access_cidrs

  # Enable IAM OIDC Provider for IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {

    admin_role = {
      principal_arn = aws_iam_role.eks_admin_role.arn
      username      = "admnin"
      access = {
        userarn = aws_iam_role.eks_admin_role.arn
        groups  = ["system:masters"]
      }
    }
  }

  eks_managed_node_groups = {
    luminous = {
      #ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3a.medium"]

      min_size = 1
      max_size = 3
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2

      # This is not required - demonstrates how to pass additional configuration
      # Ref https://bottlerocket.dev/en/os/1.19.x/api/settings/
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT

      iam_role_arn = aws_iam_role.eks_worker_role.arn
    }
  }

  tags = local.tags
}
