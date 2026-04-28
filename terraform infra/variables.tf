variable "env" {
    description = "Environment name"
    type        = string
}

variable "eks_version" {
    description = "The Kubernetes version for the EKS cluster"
    type        = string
}

variable "region_name" {
    description = "AWS region's name"
    type        = string
}

variable "zone1"{
    description = "AWS zone 1's name"
    type        = string
}

variable "zone2"{
    description = "AWS zone 2's name"
    type        = string
}
