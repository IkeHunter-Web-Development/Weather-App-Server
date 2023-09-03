data "aws_route53_zone" "zone" {
  name = "${var.dns_zone_name}."
}

resource "aws_route53_record" "server" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${lookup(var.server_subdomain, terraform.workspace)}${data.aws_route53_zone.zone.name}"
  type    = "CNAME"
  ttl     = 300

  records = [aws_lb.server.dns_name]
}

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${lookup(var.frontend_subdomain, terraform.workspace)}${data.aws_route53_zone.zone.name}"
  type    = "CNAME"
  ttl     = 300

  records = [aws_lb.server.dns_name]
}

resource "aws_acm_certificate" "server_cert" {
  domain_name       = aws_route53_record.server.fqdn
  validation_method = "DNS"

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "frontend_cert" {
  domain_name       = aws_route53_record.frontend.fqdn
  validation_method = "DNS"

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "server_cert_validation" {
  name    = tolist(aws_acm_certificate.server_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.server_cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.zone.zone_id
  records = [
    tolist(aws_acm_certificate.server_cert.domain_validation_options)[0].resource_record_value
  ]
  ttl = "60" # shortest
}

resource "aws_route53_record" "frontend_cert_validation" {
  name    = tolist(aws_acm_certificate.frontend_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.frontend_cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.zone.zone_id
  records = [
    tolist(aws_acm_certificate.frontend_cert.domain_validation_options)[0].resource_record_value
  ]
  ttl = "60" # shortest
}

resource "aws_acm_certificate_validation" "server_cert" {
  certificate_arn         = aws_acm_certificate.server_cert.arn
  validation_record_fqdns = [aws_route53_record.server_cert_validation.fqdn]
}

resource "aws_acm_certificate_validation" "frontend_cert" {
  certificate_arn         = aws_acm_certificate.frontend_cert.arn
  validation_record_fqdns = [aws_route53_record.frontend_cert_validation.fqdn]
}
