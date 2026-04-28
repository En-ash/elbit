module "ec2_sg"{
    source = "./modules/aws/security/security-group/"
    
    sg_name = "elbit-sg"
    vpc_id = module.vpc.vpc_id

    inbound = [{
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }, 
    {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },
    {        
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },
    {        
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },
    {        
        from_port   = 50000
        to_port     = 50000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }, 
    {
        from_port   = 30000
        to_port     = 32700
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ]

    outbound = [{
        from_port        = 0
        to_port          = 0
        protocol         = -1
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }]
    depends_on = [module.vpc]
}

