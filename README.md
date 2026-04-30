# elbit

# Elbit Assignment

Assignment is divided into 2 sections:
- Flask app and pipeline jobs to build and test it.
- Kubernetes cluster that implements KEDA on an app.

# First Task - Flask and Pipeline Jobs

- Creation of a Flask app that takes a GET request and outputs the list of the currently running docker containers.
- Creation of 3 pipeline jobs: 
1. Build and upload the app to Docker Hub.
2. Modify an Nginx app to forward source IP, build and upload the app to Docker Hub.
3. Pull, build and deploy the apps (both), and test reachability (HTTP 200)

## Files Overview

| File | Description |
|------|-------------|
| `job1-3` | The Jenkins' Job files |
| `main.py` | The main app's file |
| `*.Dockerfile` | Each app's Dockerfile |
| `docker-compose.yaml` | Local build file to test how both apps work together |
| `default.conf` | The modified Nginx file |

## Limitations
- Secrets are not yet implemented, thus all places where a secret should be is redacted from the files.
- Limited testing capeabilities.


# Second Task - KEDA Implementation on EKS Cluster

This Terraform configuration deploys KEDA (Kubernetes Event-driven Autoscaling) for the weather application.

## Overview of the Implementation
KEDA is implemented in this scenario on the weather app based on (currently) 3 metrics:
- Total requests per minute.
- Sum of error requests per minute.
- From 9-18 on Sunday - Thursday

## Files Relevant for the Implementation

| File | Description |
|------|-------------|
| `keda.tf` | KEDA installation and ScaledObject configuration |
| `create-app.tf` | Weather app deployment (KEDA scales this) |
| `create-eks.tf` | EKS cluster installation and configuration |
| `create-monitoring` | Setup Prometheus via Helm for KEDA triggers |


## Usage
```bash
# Initialize Terraform
terraform init

# Plan with staging variables
terraform plan -var-file=infra-staging.tfvars

# Create helm_release.monitoring First (Dependency Limitation)
terraform apply -var-file=infra-staging.tfvars -target=helm_release.monitoring

# Apply the configuration
terraform apply -var-file=infra-staging.tfvars
```


## Limitations
- Secrets are not yet implemented, thus all places where a secret should be is redacted from the files.
create-alb - domain is redacted
create-app - docker login is redacted
create-ec2 - private AMI redacted
providers  - config context for kubectl
- Comments are not implemented as of now due to time constraints.
- Limited monitoring options as the app is too simple.
