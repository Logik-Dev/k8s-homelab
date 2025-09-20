terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket                      = "opentofu"
    key                         = "k8s/${var.env}/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "https://s3.hyper.home.logikdev.fr"
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
