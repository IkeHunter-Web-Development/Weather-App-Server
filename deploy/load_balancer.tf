resource "aws_lb" "server" {
  name               = "${local.prefix}-main"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  security_groups = [aws_security_group.lb.id]

  tags = local.common_tags
}

resource "aws_lb_target_group" "server" {
  name        = "${local.prefix}-server"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 8000

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${local.prefix}-frontend"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 4200

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "server" {
  load_balancer_arn = aws_lb.server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "server_https" {
  load_balancer_arn = aws_lb.server.arn
  port              = 443
  protocol          = "HTTPS"

  # certificate_arn = aws_acm_certificate_validation.server_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}

resource "aws_lb_listener_certificate" "server" {
  listener_arn    = aws_lb_listener.server_https.arn
  certificate_arn = aws_acm_certificate_validation.server_cert.certificate_arn
}

resource "aws_lb_listener_certificate" "frontend" {
  listener_arn    = aws_lb_listener.server_https.arn
  certificate_arn = aws_acm_certificate_validation.frontend_cert.certificate_arn
}

# resource "aws_lb_listener" "frontend" {
#   load_balancer_arn = aws_lb.server.arn
#   port = 80
#   protocol = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port = "443"
#       protocol = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# resource "aws_lb_listener" "frontend" {
#   load_balancer_arn = aws_lb.server.arn
#   port              = 4200
#   protocol          = "HTTPS"

#   certificate_arn = aws_acm_certificate_validation.frontend_cert.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend.arn
#   }
# }

resource "aws_lb_listener_rule" "server" {
  listener_arn = aws_lb_listener.server_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.server.fqdn]
    }
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.server_https.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.frontend.fqdn]
    }
  }
}

resource "aws_security_group" "lb" {
  description = "Allow access to Application Load Balancer"
  name        = "${local.prefix}-lb"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 4200
    to_port     = 4200
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
