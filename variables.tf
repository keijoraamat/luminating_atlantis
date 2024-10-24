variable "aws_region" {
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application"
  default     = "luminating_atlantis"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.31"
}

variable "github_user" {
  description = "Name of the Atlantis GitHub user"
  type        = string
  default     = "DEMO_FOR_PR"
}

variable "github_token" {
  description = "	Personal access token for the Atlantis GitHub user"
  type        = string
  default     = "please_generate_your_token"
}

variable "github_secret" {
  description = "Repository or organization-wide webhook secret for the Atlantis GitHub integration. All repositories in GitHub that are to be integrated with Atlantis must share the same value"
  type        = string
  default     = "please_generate_secret_string"
}

variable "github_orgAllowlist" {
  description = "Allowlist of repositories from which Atlantis will accept webhooks. This value must be set for Atlantis to function correctly. Accepts wildcard characters (*). Multiple values may be comma-separated."
  type        = string
  default     = "github.com/YOUR_ORG_OR_USERNAME/*"
}
