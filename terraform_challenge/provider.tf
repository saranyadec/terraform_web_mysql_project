# Specify the provider
provider "aws" {
  region = var.region
#   access_key = "${var.access_key}"
#   secret_key = "${var.secret_key}"
}

terraform {
  required_version = ">= 1.8.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
  backend "s3" {
    bucket  = "kbt-md-frontend"
    key     = "webproj.terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }

}
