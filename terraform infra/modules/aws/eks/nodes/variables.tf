variable "eks_name" {
    type = string
    default = "eks-cluster"
}

variable "eks_version"{
    type = string
}

variable "node_group_name" {
    type = string
}

variable "instance_types"{
    type = list(string)
}



variable "subnet_ids"{
    type = list(string)
}



variable "eks_node_iam_role_name" {
  type = string
}
variable "eks_node_iam_role_arn" {
  type = string
}



variable "eks_nodes_policy_attachment"{
    type = set(string)
}

variable "labels" {
    type = map(string)
    default = {}
}

variable "tags" {
    type = map(string)
    default = {}
}