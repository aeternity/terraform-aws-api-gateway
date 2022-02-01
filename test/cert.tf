resource "aws_acm_certificate" "cert" {
  domain_name               = local.api_domain
  subject_alternative_names = local.api_aliases
  validation_method         = "DNS"
}


resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.ops_aeternity_com_zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = concat(
    [for record in aws_route53_record.cert_validation : record.fqdn],
    [for record in aws_route53_record.cert_validation_alt1 : record.fqdn]
  )
}
