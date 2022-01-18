module "dev" {
  source = "../../"

  sls_service_name = "api"
  sls_stage        = "dev"

  zone_name    = "example.com"
  domain_names = ["api-dev.example.com"]

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}


module "prod" {
  source = "../../"

  sls_service_name = "api"
  sls_stage        = "prod"

  zone_name    = "example.com"
  domain_names = ["api.example.com"]

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}
