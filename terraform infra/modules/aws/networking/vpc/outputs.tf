output "vpc_id" {
    value = aws_vpc.this.id
}
output "public_subnet_obj" {
    value = { for name, net in aws_subnet.public : name => net.id }
}

output "public_subnet_ids" {
    value = [ for net in aws_subnet.public : net.id ]
}

output "private_subnet_obj" {
    value = { for name, net in aws_subnet.private : name => net.id }
}

output "private_subnet_ids" {
    value = [ for net in aws_subnet.private : net.id ]
}

output "igw_id" {
    value = aws_internet_gateway.this.id
}