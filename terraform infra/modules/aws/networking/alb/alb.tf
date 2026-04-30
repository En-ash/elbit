resource "aws_lb" "this" {
  name               = "${var.env_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.sg_ids
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
    for_each    = var.target_groups
    name        = substr("${aws_lb.this.name}-${each.value.name}-tg", 0, 26)
    port        = each.value.port
    protocol    = each.value.protocol
    vpc_id      = var.vpc_id
    target_type = each.value.target_type
    health_check {
      enabled             = true
      path                = "/${each.value.path}"
      port                = "traffic-port"
      protocol            = "HTTP"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout             = 5
      interval            = 30
      matcher             = "200"
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  for_each         = var.ec2_group_attachments # Map of your 2 EC2 IDs
  target_group_arn = aws_lb_target_group.this[each.key].arn
  target_id        = each.value.ec2_id
  port             = each.value.port
}