module "vpc"{
    source = "./modules/aws/networking/vpc"

    env_name = "staging"
    vpc_name = "testing"
    vpc_cidr = "10.0.0.0/16"
    public_subnets = {
        a = {
            cidr = "10.0.1.0/24"
            az = "us-east-1a"
        }
        b = {
            cidr = "10.0.5.0/24"
            az = "us-east-1b"
        }
    }

    private_subnets = {
        c = {
            cidr = "10.0.2.0/24"
            az = "us-east-1a"
        }
        d = {
            cidr = "10.0.6.0/24"
            az = "us-east-1b"
        }
    }

    public_routes = [
            {
                cidr_block = "0.0.0.0/0"
            }
        ]
    private_routes = [
        {
            cidr_block = "0.0.0.0/0"
            nat_gateway_id = module.nat.public_nat_gateway_id
        }
    ]
}

# Nat GW for Routing
module "nat" {
    source = "./modules/aws/networking/nat"

    subnet_id = module.vpc.public_subnet_ids[0]
    is_public = true
    env_name = var.env
}

# for routing ssm internally
resource "aws_vpc_endpoint" "ssm" {
    for_each = toset(["ssm", "ec2messages", "ssmmessages"])
    vpc_id            = module.vpc.vpc_id
    service_name      = "com.amazonaws.${var.region_name}.${each.value}"
    vpc_endpoint_type = "Interface"
    subnet_ids        = module.vpc.private_subnet_ids

    security_group_ids  = [ module.ec2_sg.sg_id ]
    private_dns_enabled = true

    tags = {
        Name = "${var.env}-${each.value}-endpoint"
    }

}
