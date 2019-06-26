# terraform-aws-api-gateway

## Usage: 
A certificate resource (`cert`) with a certificate needs to be created in the root module and pass the ARN as `certificate_arn`

* For automatic validation: use `aws_acm_certificate_validation` and pass `aws_acm_certificate_validation.cert.certificate_arn.cert.certificate_arn` 
(see [test.tf](./test/test.tf))

* For manual validation: create simple `aws_acm_certificate` and pass `aws_acm_certificate.cert.arn` (apply may fail until validation is complete)
