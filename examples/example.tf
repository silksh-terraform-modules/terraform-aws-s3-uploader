module "example_cloudfront" {
  source = "github.com/silksh-terraform-modules/terraform-aws-cloudfront-s3-origin?ref=v0.0.3"

  app_domain_name = "example.com"
  source_bucket = "example.com"


  # other things
}

module "example_cloudfront2" {
  source = "github.com/silksh-terraform-modules/terraform-aws-cloudfront-s3-origin?ref=v0.0.3"

  app_domain_name = "www.example.com"
  source_bucket = "examplebucket"

  # other things
}

module "example" {
  source = "github.com:silksh-terraform-modules/terraform-aws-s3-uploader?ref=v0.0.1"

  tlds = [
    {
      domain = module.example_cloudfront.app_domain_name,
      bucket = module.example_cloudfront.source_bucket
    },
    {
      domain = module.example_cloudfront2.app_domain_name,
      bucket = module.example_cloudfront2.source_bucket
    }
  ]
  env_scope = "branch"
}