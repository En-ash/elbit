
#########################
### General
#########################

variable "env_name" {
    description = "Environment name"
    type = string
}
#########################


variable "ami" {
    description = "The AMI for the required EC2"
    type = string
}
variable "ec2_name" {
    description = "EC2's name"
    type = string
}
variable "instance_type" {
    description = "The EC2 instance type"
    type = string
}

variable "subnet_id" {
    description = "The EC2 main subnet ID"
    type = string
}

variable "security_group_ids"{
    description = "The EC2 attached security group IDs"
    type = list(string)
}

variable "tags" { 
    type = map(string)
    default = null
}


variable "iam_instance_profile_name" {
    description = "The EC2 IAM instance profile - name"
    type = string
}
variable "iam_role_name" {
    description = "The EC2 IAM instance role - name"
    type = string
}