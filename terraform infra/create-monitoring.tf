resource "kubernetes_service_v1" "app" {
  metadata {
    name = "weather"
    labels = {
      app = "weather"
    }
  }

  spec {
    selector = {
      app = "weather"
    }

    port {
      name        = "metrics"
      port        = 80
      target_port = 5000
    }
  }
}

resource "kubernetes_manifest" "weather_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "weather-service-monitor"
      namespace = "weather"
      labels = {
        release = "kube-prometheus" 
      }
    }
    spec = {
  
      selector = {
        matchLabels = {
          app = "weather"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "15s"
        }
      ]
      namespaceSelector = {
        matchNames = ["weather"]
      }
    }
    
  }

  depends_on = [helm_release.monitoring]
}

resource "helm_release" "monitoring" {
  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = true

  values = [yamlencode({
    prometheus = {
      prometheusSpec = {
        storageSpec = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = "gp2"
              accessModes      = ["ReadWriteOnce"]
              resources = {
                requests = {
                  storage = "20Gi"
                }
              }
            }
          }
        }
      }
    }
    grafana = {
        persistence = {
        enabled = true
        size    = "5Gi"
        storageClassName = "gp2"
        }
    }
  })]
}