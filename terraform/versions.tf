terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.74.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.3"
    }
  }
  required_version = ">= 1.9"
}
