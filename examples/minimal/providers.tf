provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "secondary"
  region = "eu-west-3"
}
