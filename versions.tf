# Specify required provider versions below
terraform {
  required_version = "~> 1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
      configuration_aliases = [
        aws.secondary
      ]
    }
  }
}
