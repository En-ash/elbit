variable "sg_name"{
    type = string
    default = null
}

variable "vpc_id"{
    type = string
    default = null
}

variable "inbound" {
    type = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
    }))
    default = [{
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }]
}

variable "outbound" {
    type = list(object({
        from_port        = number
        to_port          = number
        protocol         = string
        cidr_blocks      = list(string)
        ipv6_cidr_blocks = list(string)
    }))
    default = [{
        from_port        = 0
        to_port          = 0
        protocol         = -1
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
  }]
}

variable "tags" {
    type = map(string)
    default = null
}