//EC2 are generic compute, it needs a role wrapped in an instance profile
resource "aws_iam_instance_profile" "this" {
    name = var.iam_instance_profile_name
    role = var.iam_role_name
}

resource "aws_instance" "this" {
    ami           = "${var.ami}"
    instance_type = "${var.instance_type}"
    subnet_id     = var.subnet_id

    vpc_security_group_ids = var.security_group_ids

    iam_instance_profile = var.iam_instance_profile_name

    tags = merge(var.tags, {
        Name = "${var.env_name} - ${var.ec2_name}"
    })
}

