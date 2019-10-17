resource "aws_cloudfront_distribution" "api_gate" {
  enabled = true
  aliases = "${compact(concat(list(var.api_domain), var.api_aliases))}"

  origin {
    domain_name = var.lb_fqdn
    origin_id   = "api_lb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = var.mdw_fqdn
    origin_id   = "api_mdw"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["AWSALB"]
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "api_lb"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 31536000
  }

  ordered_cache_behavior {
    path_pattern    = "/middleware/*"
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "api_mdw"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.certificate_arn}"

    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = {
    env = "${var.env}"
  }
}

resource "aws_route53_record" "api_gate" {
  zone_id = "${var.dns_zone}"
  name    = "${var.api_domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.api_gate.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.api_gate.hosted_zone_id}"
    evaluate_target_health = false
  }
}
