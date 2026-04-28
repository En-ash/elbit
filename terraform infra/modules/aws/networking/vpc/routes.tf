#########################
### Routes
#########################


resource "aws_route_table" "public"{
    vpc_id = aws_vpc.this.id

    dynamic "route" {
        for_each = var.public_routes

        content {
            cidr_block      = route.value.cidr_block
            gateway_id      = aws_internet_gateway.this.id
        }
    }

    tags = {
        Name = "${var.env_name}-public-route-table"
    }
}

resource "aws_route_table" "private"{
    vpc_id = aws_vpc.this.id

    dynamic "route" {
        for_each = var.private_routes

        content {
            cidr_block      = route.value.cidr_block
            nat_gateway_id  = route.value.nat_gateway_id
        }
    }

    tags = {
        Name = "${var.env_name}-private-route-table"
    }
}
resource "aws_route_table_association" "public"{
    for_each        = aws_subnet.public
    subnet_id       = each.value.id
    route_table_id  = aws_route_table.public.id
}

resource "aws_route_table_association" "private"{
    for_each        = aws_subnet.private
    subnet_id       = each.value.id
    route_table_id  = aws_route_table.private.id
}

#########################
