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

resource "helm_release" "atlantis" {
  depends_on = [module.eks]

  name       = "atlantis"
  chart      = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  version    = "5.7.0"

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
    name  = "volumeClaim.enabled"
    value = "false"
  }

  timeout = 600
  wait    = true
}
