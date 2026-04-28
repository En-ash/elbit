#########################
### VPC
#########################

resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr

    // required by some addons like EFS CSI or client VPN
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(var.vpc_tags, {
        Name = var.vpc_name
    })
}

#########################


#########################
### Subnets
#########################

resource "aws_subnet" "public" {
    for_each = var.public_subnets
    
    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value.cidr
    availability_zone       = each.value.az
    map_public_ip_on_launch = true

    tags = merge(var.subnet_public_tags, {
        Name = "${var.vpc_name}-public-${each.key}"
    })
}

resource "aws_subnet" "private" {
    for_each = var.private_subnets
    
    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value.cidr
    availability_zone       = each.value.az

    tags = merge(var.subnet_private_tags, {
        Name = "${var.vpc_name}-private-${each.key}"
    })
}

#########################
