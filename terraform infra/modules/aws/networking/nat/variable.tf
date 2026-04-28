
#########################
### General
#########################

variable "env_name" {
    description = "Environment name"
    type = string
}
#########################


#########################
### nat-gw
#########################

variable "subnet_id" {
    type = string
    default = null
}

variable "is_public" {
  type    = bool
  default = true
}

variable "conn_type" {
    type = string
    default = "private"
}

#########################
