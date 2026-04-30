
# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  //certificate_arn   = data.aws_acm_certificate.this.arn
  certificate_arn   =  "arn:aws:acm:us-east-1:067270456917:certificate/315a1665-09fc-41e8-92a6-2a8725f3cc36"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

# Rule 1: Route domain to EKS
resource "aws_lb_listener_rule" "eks" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this["eks"].arn
  }

  condition {
    host_header {
      values = ["app.${var.domain}"]
    }
  }
}

# Rule 2: Route legacy.example.com to EC2
resource "aws_lb_listener_rule" "ec2_jenkins" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this["ec2_jenkins"].arn
  }

  condition {
    host_header {
      values = ["jenkins.${var.domain}"]
    }
  }
}
resource "aws_lb_listener_rule" "ec2_gitlab" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this["ec2_gitlab"].arn
  }

  condition {
    host_header {
      values = ["gitlab.${var.domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "argocd" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this["argocd"].arn
  }

  condition {
    host_header {
      values = ["argocd.${var.domain}"]
    }
  }
}

data "aws_route53_zone" "this" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "www" {
  for_each = toset( ["app.", "gitlab.", "jenkins.", "argocd.", "grafana.", ""] )
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${each.key}${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}