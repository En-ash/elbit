
#########################
### General
#########################

variable "env_name" {
    description = "Environment name"
    type = string
}
#########################


#########################
### networks.tf
#########################

variable "vpc_name" {
    description = "VPC name"
    type = string
}

variable "vpc_cidr" {
    description = "VPC's cidr notation"
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnets" {
    type = map(object({
        cidr = string
        az = string
    }))
}

variable "private_subnets" {
    type = map(object({
        cidr = string
        az = string
    }))
}

variable "subnet_private_tags" { 
    type = map(string)
    default = null
}
variable "subnet_public_tags" { 
    type = map(string)
    default = null
}
variable "vpc_tags" { 
    type = map(string)
    default = null
}
#########################


#########################
### routes.tf
#########################

variable "public_routes" {
  type = list(object({
    cidr_block = string
  }))
  default = []
}

variable "private_routes" {
  type = list(object({
    cidr_block     = string
    nat_gateway_id = string
  }))
  default = []
}

variable "public_route_association" {
    type = map(object({
        subnet_key = string
        route_table_key = string
    }))
    default = {}
}
variable "public_route_name" {
    type = string
    default = null
}

variable "private_route_association" {
    type = map(object({
        subnet = string
        route = string
    }))
    default = {}
}

variable "private_route_name" {
    type = string
    default = null
}
#########################

