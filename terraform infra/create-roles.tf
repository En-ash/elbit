module "ec2_jenkins_role" {
    source = "./modules/aws/security/iam-role/"
    role_name = "Elbit-jenkins-profile"
    service = "ec2.amazonaws.com"
}
/*
module "eks_cluster_role" {
    source = "./modules/aws/security/iam-role/"
    role_name = "${var.env}-eks-cluster-role"
    service = "eks.amazonaws.com"
}

module "eks_cluster_node_role" {
    source = "./modules/aws/security/iam-role/"
    role_name = "${var.env}-eks-cluster-node-role"
    service = "ec2.amazonaws.com"
}


resource "aws_iam_role_policy_attachment" "ssm_core" {
    for_each = toset([module.ec2_jenkins_role.role_name, module.eks_cluster_node_role.role_name])
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    role       = each.value
}
*/
resource "aws_iam_role_policy_attachment" "ssm_core" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    role       = module.ec2_jenkins_role.role_name
}
#### jenkins API Access Role

module "jenkins_access_role" {
    source = "./modules/aws/security/iam-role/"
    role_name = "${var.env}-jenkins_access_role"
    service = "eks.amazonaws.com"
}
