# KEDA Implementation

This Terraform configuration deploys KEDA (Kubernetes Event-driven Autoscaling) for the weather application.

## Overview

KEDA is installed via Helm and enables autoscaling based on multiple triggers:
- Prometheus metrics (request rate)
- Prometheus metrics (error rate)
- Cron-based scheduling

## Files

| File | Description |
|------|-------------|
| `keda.tf` | KEDA installation and ScaledObject configuration |
| `create-app.tf` | Weather app deployment (KEDA scales this) |
| `variables.tf` | Input variables |
| `infra-staging.tfvars` | Staging environment values |

## KEDA Configuration

### Installation
```hcl
resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = "keda"
}
```

### ScaledObject
The `weather-app` deployment is configured with autoscaling:

```hcl
resource "kubernetes_manifest" "weather_app_scaler" {
  spec = {
    scaleTargetRef = { name = "weather-app" }
    minReplicaCount = 1
    maxReplicaCount = 10
    triggers = [
      # 1. Prometheus: scale on request rate
      {
        type = "prometheus"
        metadata = {
          threshold = "10"        # 10 RPS threshold
          query = "sum(rate(app_requests_total[1m]))"
        }
      },
      # 2. Prometheus: scale on 5xx error rate
      {
        type = "prometheus"
        metadata = {
          threshold = "0.05"      # 5% error rate
          query = "sum(rate(http_requests_total{status=~'5..'}[1m])) / sum(rate(http_requests_total[1m]))"
        }
      },
      # 3. Cron: scale during work hours
      {
        type = "cron"
        metadata = {
          timezone = "Asia/Jerusalem"
          start    = "0 9 * * 0-4"    # 9 AM Sun-Thu
          end      = "0 18 * * 0-4"    # 6 PM Sun-Thu
          desiredReplicas = "2"
        }
      }
    ]
  }
}
```

## Triggers

| Trigger | Type | Condition |
|---------|------|-----------|
| Request rate | Prometheus | ≥10 requests/sec |
| Error rate | Prometheus | ≥5% 5xx errors |
| Business hours | Cron | Sun-Thu 09:00-18:00 IST |

## Usage

```bash
# Initialize Terraform
terraform init

# Plan with staging variables
terraform plan -var-file=infra-staging.tfvars

# Apply the configuration
terraform apply -var-file=infra-staging.tfvars
```

## Dependencies

- EKS cluster (`module.eks`) must be provisioned
- Prometheus monitoring must be running in `monitoring` namespace

## Outputs

KEDA automatically manages the replica count of the `weather-app` deployment based on the triggers defined above.