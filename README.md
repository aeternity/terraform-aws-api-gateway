# terraform-aws-api-gateway

## Usage: 
A certificate resource (e.g. `cert`) needs to be created in the root module then the [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) passed as `certificate_arn` (string):

* For automatic validation: use `aws_acm_certificate_validation` and pass `aws_acm_certificate_validation.cert.certificate_arn.cert.certificate_arn` 
(see [test.tf](./test/test.tf))

* For manual validation: create simple `aws_acm_certificate` and pass `aws_acm_certificate.cert.arn` (`terraform apply` may fail until domain validation is complete)
