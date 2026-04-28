output "public_nat_gateway_id" {
    value = aws_nat_gateway.public[0].id
}
