output "eks_cluster_name" {
  value      = module.eks.cluster_id
  depends_on = [module.eks]
}

output "vpc_id" {
  value      = module.vpc.vpc_id
  depends_on = [module.vpc]
}

output "private_subnet" {
  value      = module.vpc.private_subnets
  depends_on = [module.vpc]
}

output "oidc_provider_arn" {
  value      = module.eks.oidc_provider_arn
  depends_on = [module.eks]
}

output "oidc_provider_url" {
  value      = module.eks.oidc_provider
  depends_on = [module.eks]
}

# output "nginx_ingress_loadbalancer_ip" {
#   value       = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname
#   description = "The external IP of the NGINX Ingress LoadBalancer"
#   depends_on  = [module.eks]
# }
