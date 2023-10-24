resource "aws_route53_record" "api-gw-r53" {
  zone_id = var.auth-api-r53-zone-id

  name    = aws_api_gateway_domain_name.api-gw-dns.domain_name
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_api_gateway_domain_name.api-gw-dns.regional_domain_name}"]
}
