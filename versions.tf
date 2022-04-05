# Specify required provider versions below
terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.7"
      configuration_aliases = [
        aws.secondary
      ]
    }
  }
}
