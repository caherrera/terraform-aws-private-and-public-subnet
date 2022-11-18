data "aws_vpc" "main" {
  tags = { Name = "Safe Trice VPC" }

}

data "aws_availability_zones" "available" {}

locals {
  count_with_nat = var.use_nat == true ? var.az_count : 0
}