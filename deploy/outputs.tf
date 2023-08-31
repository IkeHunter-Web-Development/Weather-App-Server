output "db_host" {
  value = aws_db_instance.main.address
}

output "bastion_host" {
  value = aws_instance.bastion.public_dns
}

output "server_endpoint" {
  value = aws_route53_record.server.fqdn
}

output "frontend_endpoint" {
  value = aws_route53_record.frontend.fqdn
}