output "origin-api-name" {
  value = "${aws_route53_record.origin-api.0.name}"
}

output "main-api-name" {
  value = "${aws_route53_record.main-api.0.name}"
}
