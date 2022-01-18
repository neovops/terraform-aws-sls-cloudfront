/**
 * [![Neovops](https://neovops.io/images/logos/neovops.svg)](https://neovops.io)
 *
 * # Terraform AWS Serverless Framework Cloudfront module
 *
 * Terraform module to provision a cloudfront distibution in front of a
 * Serverless Framework stack. This module retrieve the api gateway domain
 * directly from the CloudFormation stack deployed by sls (Serverless
 * Framework).
 *
 * ## Terraform registry
 *
 * This module is available on
 * [terraform registry](https://registry.terraform.io/modules/neovops/sls-cloudfront/aws/latest).
 *
 * ## Example
 *
 * ```hcl
 * provider "aws" {
 *   region = "eu-west-1"
 * }
 *
 * # ACM Certificate must be created in us-east-1 region for any CloudFront
 * # distribution.
 * provider "aws" {
 *   alias  = "us-east-1"
 *   region = "us-east-1"
 * }
 *
 * module "dev" {
 *   source = "../../"
 *
 *   sls_service_name = "api"
 *   sls_stage        = "dev"
 *
 *   zone_name    = "example.com"
 *   domain_names = ["api-dev.example.com"]
 *
 *   providers = {
 *     aws.us-east-1 = aws.us-east-1
 *   }
 * }
 *
 * module "prod" {
 *   source = "../../"
 *
 *   sls_service_name = "api"
 *   sls_stage        = "prod"
 *
 *   zone_name    = "example.com"
 *   domain_names = ["api.example.com"]
 *
 *   providers = {
 *     aws.us-east-1 = aws.us-east-1
 *   }
 * }
 * ```
 */

data "aws_cloudformation_stack" "sls" {
  name = "${var.sls_service_name}-${var.sls_stage}"
}

data "aws_route53_zone" "zone" {
  name = var.zone_name
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = replace(data.aws_cloudformation_stack.sls.outputs["HttpApiUrl"], "https://", "")
    origin_id   = "apigw"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled = true

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "apigw"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  aliases = var.domain_names

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.domain_names[0]
  zone_id     = data.aws_route53_zone.zone.zone_id

  subject_alternative_names = slice(var.domain_names, 1, length(var.domain_names))

  wait_for_validation = true

  tags = {
    Name = "metadata-dev"
  }

  providers = {
    aws = aws.us-east-1
  }
}

resource "aws_route53_record" "cloudfront" {
  for_each = toset(var.domain_names)

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
