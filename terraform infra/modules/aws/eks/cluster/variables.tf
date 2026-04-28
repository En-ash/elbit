variable "eks_name" {
    type = string
    default = "eks-cluster"
}

variable "eks_version"{
    type = string
}



variable "subnet_ids"{
    description = "A list of subnet IDs, min from 2 AZs"
    type = list(string)
}


variable "eks_cluster_iam_role_name" {
  type = string
}
variable "eks_cluster_iam_role_arn" {
  type = string
}


variable "eks_cluster_policy_attachment"{
    type = set(string)
}
