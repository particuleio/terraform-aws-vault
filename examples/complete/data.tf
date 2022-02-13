data "aws_region" "primary" {}

data "aws_availability_zones" "primary" {}

data "aws_region" "secondary" {
  provider = aws.secondary
}

data "aws_availability_zones" "secondary" {
  provider = aws.secondary
}
