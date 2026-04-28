resource "aws_iam_role_policy_attachment" "this" {
    for_each    = var.eks_cluster_policy_attachment
    policy_arn  = each.value
    role        = var.eks_cluster_iam_role_name
}

resource "aws_eks_cluster" "this" {
    name        = "${var.eks_name}"
    version     = var.eks_version
    role_arn    = var.eks_cluster_iam_role_arn


    vpc_config {
      endpoint_private_access = false
      endpoint_public_access  = true

      //These will be used to create worker nodes
      subnet_ids = var.subnet_ids
    }
    access_config {
        authentication_mode                         = "API"
        bootstrap_cluster_creator_admin_permissions = true
    }

    depends_on = [ aws_iam_role_policy_attachment.this ]
  
}