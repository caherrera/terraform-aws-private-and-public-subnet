data "aws_vpc" "main" {
  id = var.vpc_id

}

data "aws_availability_zones" "available" {}

locals {
  count_with_nat = var.use_nat == true ? var.az_count : 0
}