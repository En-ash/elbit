resource "kubernetes_namespace" "jenkins_ns" {
  metadata {
    name = "jenkins-system"
    labels = {
      jenkins = "slave"
    }
  }
}

resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins-api"
    namespace = "jenkins-system"
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_admin_binding" {
  metadata {
    name = "jenkins-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "jenkins-api"
    namespace = "jenkins-system"
  }
}