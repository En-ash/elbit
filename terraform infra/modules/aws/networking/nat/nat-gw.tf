#########################
### NAT
#########################
resource "aws_eip" "this" {
    count  = var.is_public ? 1 : 0
    domain = "vpc"

    tags = {
      Name = "${var.env_name}-public-nat"
    }
}

resource "aws_nat_gateway" "public"{
    count  = var.is_public ? 1 : 0
    allocation_id = aws_eip.this[0].id

    subnet_id = var.subnet_id
    
    tags = {
        Name = "${var.env_name}-public-nat"
    }

    depends_on = []
}


resource "aws_nat_gateway" "private"{
    count  = var.is_public ? 0 : 1

    subnet_id = var.subnet_id
    connectivity_type = "private"

    tags = {
        Name = "${var.env_name}-private-nat"
    }

    depends_on = []
}

#########################

