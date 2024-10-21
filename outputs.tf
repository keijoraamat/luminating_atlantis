output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet" {
  value = module.vpc.private_subnets
}
