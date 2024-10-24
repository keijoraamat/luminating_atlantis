provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster.name]
  }
}


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster.name]
    }

  }
}

data "aws_eks_cluster" "eks_cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "auth" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "kubernetes_service" "nginx_ingress" {

  depends_on = [module.eks, helm_release.nginx_ingress]
  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }

  depends_on = [module.eks]
}


resource "helm_release" "nginx_ingress" {
  depends_on = [module.eks, kubernetes_namespace.ingress_nginx]
  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  #version    = "4.0.10" # specify a version or leave it out for the latest

  values = [
    <<EOF
controller:
  service:
    type: LoadBalancer
EOF
  ]

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}

resource "helm_release" "atlantis" {
  depends_on = [module.eks, helm_release.nginx_ingress]

  name       = "atlantis"
  chart      = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  #version    = "5.7.0"

  set {
    name  = "github.user"
    value = var.github_user
  }

  set {
    name  = "github.token"
    value = var.github_token
  }

  set {
    name  = "github.secret"
    value = var.github_secret
  }

  set {
    name  = "orgAllowlist"
    value = var.github_orgAllowlist
  }

  set {
    name  = "volumeClaim.storageClassName"
    value = "gp2"
  }

  # Ingress Configuration
  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.ingressClassName"
    value = ""
  }

  set {
    name  = "ingress.apiVersion"
    value = "networking.k8s.io/v1"
  }

  # Annotations
  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  # Single Host Configuration
  set {
    name  = "ingress.host"
    value = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname
  }

  set {
    name  = "ingress.path"
    value = "/*"
  }

  set {
    name  = "ingress.pathType"
    value = "Prefix"
  }

  # Backend Service Configuration
  set {
    name  = "ingress.service"
    value = "atlantis"
  }

  set {
    name  = "ingress.port"
    value = "80"
  }


  timeout = 600
  wait    = true
}
