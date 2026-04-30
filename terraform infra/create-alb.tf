module "alb" {
    source = "./modules/aws/networking/alb"

    domain = "REDACTED"
    env_name = var.env
    vpc_id = module.vpc.vpc_id

    sg_ids = [ module.ec2_sg.sg_id ]

    public_subnet_ids = module.vpc.public_subnet_ids
    
    target_groups = {
        eks = {
            name        = "eks"
            port        = 30079
            protocol    = "HTTP"
            target_type = "instance"
            path        = ""
        },
        ec2_gitlab = {
            name        = "ec2-gitlab"
            port        = 80
            protocol    = "HTTP"
            target_type = "instance"
            path        = "users/sign_in"
        },
        ec2_jenkins = {
            name        = "ec2-jenkins"
            port        = 8080
            protocol    = "HTTP"
            target_type = "instance"
            path        = "login"
        },
        argocd = {
            name        = "argocd"
            port        = 30080
            protocol    = "HTTP"
            target_type = "instance"
            path        = "healthz"
        }
    }
    ec2_group_attachments = {
        ec2_gitlab = {
            ec2_id = module.gitlab.ec2_id
            port = 80
        },
        ec2_jenkins = {
            ec2_id = module.jenkins.ec2_id
            port = 8080
        }
    }
}

resource "aws_autoscaling_attachment" "argocd"{
    autoscaling_group_name = module.eks.eks_managed_node_groups["production"].node_group_autoscaling_group_names[0]
    lb_target_group_arn     = module.alb.target_group_arns["argocd"]
}

resource "aws_autoscaling_attachment" "app"{
    autoscaling_group_name = module.eks.eks_managed_node_groups["production"].node_group_autoscaling_group_names[0]
    lb_target_group_arn     = module.alb.target_group_arns["eks"]
}