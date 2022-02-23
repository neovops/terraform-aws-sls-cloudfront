<!-- BEGIN_TF_DOCS -->
[![Neovops](https://neovops.io/images/logos/neovops.svg)](https://neovops.io)

# Terraform AWS Serverless Framework Cloudfront module

Terraform module to provision a cloudfront distibution in front of a
Serverless Framework stack. This module retrieve the api gateway domain
directly from the CloudFormation stack deployed by sls (Serverless
Framework).

## Terraform registry

This module is available on
[terraform registry](https://registry.terraform.io/modules/neovops/sls-cloudfront/aws/latest).

## Example

```hcl
provider "aws" {
  region = "eu-west-1"
}

# ACM Certificate must be created in us-east-1 region for any CloudFront
# distribution.
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "dev" {
  source = "neovops/sls-cloudfront/aws"

  sls_service_name = "api"
  sls_stage        = "dev"

  zone_name    = "example.com"
  domain_names = ["api-dev.example.com"]

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}

module "prod" {
  source = "neovops/sls-cloudfront/aws"

  sls_service_name = "api"
  sls_stage        = "prod"

  zone_name    = "example.com"
  domain_names = ["api.example.com"]

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_route53_record.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_cloudformation_stack.sls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudformation_stack) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names | `list(string)` | n/a | yes |
| <a name="input_sls_service_name"></a> [sls\_service\_name](#input\_sls\_service\_name) | Serverless Framework service name | `string` | n/a | yes |
| <a name="input_sls_stage"></a> [sls\_stage](#input\_sls\_stage) | Serverless Framework stage | `string` | n/a | yes |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Route53 zone name. It must already exists. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->