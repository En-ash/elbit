module "jenkins" {
    source = "./modules/aws/infrastructure/ec2"
    env_name = var.env
    ec2_name = "jenkins"
    ami = "ami-03b28580948af23e5"
    instance_type = "t3.small"
    subnet_id = module.vpc.private_subnet_obj["c"]

    security_group_ids = [module.ec2_sg.sg_id]

    iam_role_name = module.ec2_jenkins_role.role_name
    iam_instance_profile_name = "Elbit-jenkins-profile"

    depends_on = [module.vpc, module.ec2_jenkins_role, module.ec2_sg]
}