resource "kubernetes_deployment_v1" "weather_app" {
  metadata {
    name      = "weather-app"
    namespace = "weather"
    labels = {
      app = "weather"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "weather"
      }
    }

    template {
      metadata {
        labels = {
          app = "weather"
        }
      }

      spec {
        image_pull_secrets {
          name = "my-dockerhub-secret"
        }

        container {
          image = "ayashben/weather_app:latest"
          name  = "weather-container"

          port {
            container_port = 5000
            protocol       = "TCP"
          }

          env {
            name  = "HOST"
            value = "0.0.0.0"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
resource "kubernetes_secret_v1" "dockerhub_creds" {
  metadata {
    name      = "dockerhub-secret"
    namespace = "weather" 
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          auth = base64encode("REDACTED")
        }
      }
    })
  }
}
resource "kubernetes_service_v1" "weather_service" {
  metadata {
    name      = "weather-service"
    namespace = "weather"
    labels = {
      app = "weather"
    }
  }

  spec {
    selector = {
      app = "weather"
    }

  type     = "NodePort" 
    port {
      name        = "metrics"
      port        = 80
      target_port = 5000
      node_port   = 30079
    }
  }
}


resource "kubernetes_ingress_v1" "weather_ingress" {
  metadata {
    name      = "weather-ingress"
    namespace = "weather"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"        = "instance"
      "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-2016-08"
      "alb.ingress.kubernetes.io/actions.weather-service" = "{\"Type\": \"forward\", \"TargetGroupArn\": \"${module.alb.target_group_arns["eks"]}\"}"
    }
  }
  spec {
    ingress_class_name = "alb"

    rule {
      host = "app.sponja.co.il"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.weather_service.metadata[0].name
              port {
                number = 80 
              }
            }
          }
        }
      }
    }
  }
}

