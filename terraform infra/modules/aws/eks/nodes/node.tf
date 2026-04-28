resource "aws_iam_role_policy_attachment" "this" {
    for_each    = var.eks_nodes_policy_attachment
    policy_arn  = each.value
    role        = var.eks_node_iam_role_name
}


resource "aws_eks_node_group" "this" {
    cluster_name    = var.eks_name
    version         = var.eks_version
    node_group_name = var.node_group_name
    node_role_arn   = var.eks_node_iam_role_arn

    subnet_ids = var.subnet_ids

    capacity_type = "ON_DEMAND"
    instance_types = var.instance_types

    scaling_config {
        desired_size    = 1
        max_size        = 10
        min_size        = 0
    }

    update_config {
        max_unavailable = 1
    }

    labels = merge(var.labels, {
        role = "general"
    })

    tags = {
        Name = "${var.node_group_name}"
        NodeGroup   = var.node_group_name
        ClusterName = var.eks_name
    }

    depends_on = [ aws_iam_role_policy_attachment.this ]

    lifecycle {
        ignore_changes = [ scaling_config[0].desired_size ]
    }
  
}