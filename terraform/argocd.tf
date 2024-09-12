rovider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
  }
}

resource "kubernetes_service_account" "argocd_admin" {
  metadata {
    name      = "argocd-admin"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
}

resource "kubernetes_manifest" "argocd_install" {
  manifest = yamldecode(file("https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"))
  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "argocd-server"
    }

    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    password = base64decode(kubernetes_secret.argocd_initial_admin_secret.data["password"])
  }
}

resource "kubernetes_manifest" "argo_cd_applications" {
  manifest = yamldecode(file("../argo-cd/applications.yaml"))
  depends_on = [kubernetes_namespace.argocd]
}

output "argocd_password" {
  value = base64decode(kubernetes_secret.argocd_initial_admin_secret.data["password"])
}

output "argocd_server_url" {
  value = kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
}