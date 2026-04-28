##############################
## General
##############################

variable "domain" {
    type = string
}

variable "env_name" {
    type = string
}

variable "vpc_id" {
    type = string
}


##############################
## ALB Creation
##############################

variable "public_subnet_ids" {
    type = list (string)
}

variable "sg_ids" {
    type = list(string)
}

variable "target_groups"{
    type = map(object({
        name          = string,
        port          = number,
        protocol      = string,
        target_type   = string,
        path          = string
    }))
}

variable "ec2_group_attachments" {
    type = map(object({
        ec2_id      = string,
        port        = number
    }))
}


##############################
## Listeners and Rules
##############################


