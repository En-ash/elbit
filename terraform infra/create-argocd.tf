data "aws_eks_cluster_auth" "main" {
 name = module.eks.cluster_name
}

resource "helm_release" "argocd" {
  depends_on = [module.eks.eks_managed_node_groups]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "4.5.2"

  namespace = "argocd"
  timeout = 600   # 10 minutes
  wait    = true

  create_namespace = true

  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  set {
    name  = "server.service.nodePort"
    value = "30080"
  }
  set {
    name  = "server.service.targetPort"
    value = "8080"
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  set {
    name  = "server.enable.tls"
    value = "false"
  }

  set {
  name  = "configs.secret.createSecret"
  value = "true"
  }

}


data "kubernetes_service" "argocd_server" {
 metadata {
   name      = "argocd-server"
   namespace = helm_release.argocd.namespace
 }
}
locals {
  node_asg_name = module.eks.eks_managed_node_groups["production"].node_group_autoscaling_group_names[0]
}

resource "aws_autoscaling_attachment" "argocd_attach" {
  autoscaling_group_name = local.node_asg_name
  lb_target_group_arn    = module.alb.target_group_arns["argocd"]
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "weather"
  }
}