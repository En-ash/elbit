/*
module "aws_eks_cluster" {
    source = "../65_eks_project/modules/aws/eks/cluster/"
    eks_name = "${var.env}-eks-cluster"
    eks_version = var.eks_version

    eks_cluster_iam_role_arn = module.eks_cluster_role.role_arn
    eks_cluster_iam_role_name = module.eks_cluster_role.role_name

    eks_cluster_policy_attachment = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]


    subnet_ids = [module.vpc.private_subnet_obj["c"], module.vpc.private_subnet_obj["d"]]
}

module "eks_nodes_apps" {
    source = "../65_eks_project/modules/aws/eks/nodes/"
    eks_name = module.aws_eks_cluster.eks_name
    eks_version = var.eks_version
    node_group_name = "${module.aws_eks_cluster.eks_name}-nodeGroup-${var.env}"

    instance_types = [ "t3.small" ]
    subnet_ids = [module.vpc.private_subnet_obj["c"]]

    eks_node_iam_role_arn  = module.eks_cluster_node_role.role_arn
    eks_node_iam_role_name = module.eks_cluster_node_role.role_name

    eks_nodes_policy_attachment = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ]

    tags = {
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${module.aws_eks_cluster.eks_name}" = "owned"
    }
    
    depends_on = [ module.eks_cluster_node_role ]
}
*/

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.18.0"

  name               = "${var.env}-eks-cluster-2"
  kubernetes_version = var.eks_version

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # Optional
  endpoint_public_access = true
  endpoint_private_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
  
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    system_node = {
      name = "system-managed-workers"
      instance_types = ["m7i-flex.large"]

      min_size     = 1
      max_size     = 10
      desired_size = 1

      taints = {
        critical_addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }

        system = {
          key    = "system"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }

      labels = {
        "node.kubernetes.io/scope"        = "system"
        "Environment"                     = "dev"
        nodepool                          = "system"
      }

    }
    staging = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 10
      desired_size = 1
      
      labels = {
        jenkins = "slave"
        env  = "staging"
      }
    }
    development = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t3.small"]

      min_size     = 0
      max_size     = 10
      desired_size = 0
      
      labels = {
        jenkins = "slave"
        env  = "development"
      }
    }
    production = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      name = "Production"

      instance_types = ["m7i-flex.large"]

      min_size     = 1
      max_size     = 10
      desired_size = 1
      
      labels = {
        jenkins = "slave"
        env  = "production"
      }
    }
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
  }

  security_group_additional_rules = {
    ingress_https_api = {
      description              = "Jenkins / ArgoCD EC2 to EKS API"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = module.ec2_sg.sg_id 
    }
  }

  # This allows Jenkins pods (running on nodes) to talk back to Jenkins
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_alb_argocd = {
      description              = "Allow ALB to ArgoCD NodePort"
      protocol                 = "tcp"
      from_port                = 30000
      to_port                  = 32700
      type                     = "ingress"
      source_security_group_id = module.ec2_sg.sg_id
    }
  }
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    jenkins_admin = {
      principal_arn = module.jenkins_access_role.role_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" 
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

