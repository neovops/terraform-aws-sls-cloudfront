variable "sls_service_name" {
  type        = string
  description = "Serverless Framework service name"
}

variable "sls_stage" {
  type        = string
  description = "Serverless Framework stage"
}

variable "zone_name" {
  type        = string
  description = "Route53 zone name. It must already exists."
}

variable "domain_names" {
  type        = list(string)
  description = "Domain names"
}

variable "web_acl_id" {
  type        = string
  description = "Unique identifier that specifies the AWS WAF web ACL"
  default     = ""
}
