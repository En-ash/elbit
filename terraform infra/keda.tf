resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = "keda"
  create_namespace = true

  depends_on = [module.eks] 
}

resource "kubernetes_manifest" "weather_app_scaler" {
  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "ScaledObject"
    metadata = {
      name      = "weather-app-scaler"
      namespace = "weather"
    }
    spec = {
      scaleTargetRef = {
        name = "weather-app" 
      }
      minReplicaCount = 1
      maxReplicaCount = 10
      triggers = [
        {
          type = "prometheus"
          metadata = {
            serverAddress = "http://kube-prometheus-kube-prome-prometheus.monitoring.svc.cluster.local:9090"
            metricName    = "app_requests_total"
            # every every 10 requests per second
            threshold     = "10"
            query         = "sum(rate(app_requests_total[1m]))"
          }
        },
        {
          type = "prometheus"
          metadata = {
            serverAddress = "http://kube-prometheus-kube-prome-prometheus.monitoring.svc.cluster.local:9090"
            metricName    = "app_requests_total"
            # per error rates
            query = "sum(rate(http_requests_total{status=~'5..'}[1m])) / sum(rate(http_requests_total[1m]))"
            threshold = "0.05"
          }
        },
        {
            type = "cron"
            metadata = {
                timezone        = "Asia/Jerusalem"
                start           = "0 9 * * 0-4" # 9 AM Sun-Thu
                end             = "0 18 * * 0-4" # 6 PM Sun-Thu
                desiredReplicas = "2"
            }
        }
      ]
    }
  }
}

