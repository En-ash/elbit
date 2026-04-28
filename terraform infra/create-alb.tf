module "alb" {
    source = "./modules/aws/networking/alb"

    domain = "sponja.co.il"
    env_name = var.env
    vpc_id = module.vpc.vpc_id

    sg_ids = [ module.ec2_sg.sg_id ]

    public_subnet_ids = module.vpc.public_subnet_ids
    
    target_groups = {
        ec2_jenkins = {
            name        = "ec2-jenkins"
            port        = 8080
            protocol    = "HTTP"
            target_type = "instance"
            path        = "login"
        }
    }
    ec2_group_attachments = {
        ec2_jenkins = {
            ec2_id = module.jenkins.ec2_id
            port = 8080
        }
    }
}
