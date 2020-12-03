variable "base_url" {
  default = "https://edition.cnn.com"
}

module "first" {
  source    = "./webproxy"
  name = "first"
  base_url = var.base_url
  providers = {
    aws = aws.us-east-1
  }
}
output "first" { value = module.first.invoke_url }

module "second" {
  source    = "./webproxy"
  name = "second"
  base_url = var.base_url
  providers = {
    aws = aws.eu-west-1
  }
}
output "second" { value = module.second.invoke_url }
