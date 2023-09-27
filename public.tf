data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

resource "aws_internet_gateway" "igw" {
  count = length(data.aws_internet_gateway.igw) ==0 ? 1 : 0
}

resource "aws_internet_gateway_attachment" "igw-vpc" {
  count               = length(data.aws_internet_gateway.igw) ==0 ? 1 : 0
  internet_gateway_id = aws_internet_gateway.igw[0].id
  vpc_id              = data.aws_vpc.main.id
}

locals {
  public_netnum_offset = coalesce(var.netnum_offset, var.public_netnum_offset )
  public_extra_offset  = 0
}

### Public Subnet, Nat and Route Tables
resource "aws_subnet" "public_subnet" {
  count             = var.az_count
  cidr_block        = coalesce(var.public_cidr_block, cidrsubnet(data.aws_vpc.main.cidr_block, var.newbits, count.index + local.public_extra_offset + local.public_netnum_offset))
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = data.aws_vpc.main.id
  tags              = merge({
    Name = "Public ${data.aws_availability_zones.available.names[count.index]}"
  }, var.public_tags)
}

resource "aws_eip" "nat" {
  count = local.count_with_nat
  domain   = "vpc"
  tags  = { Name = "ngw-eip-${aws_subnet.public_subnet[count.index].availability_zone}" }

}

resource "aws_route_table" "public" {
  count  = var.az_count
  vpc_id = data.aws_vpc.main.id
  tags   = { Name = "${var.name} public ${aws_subnet.public_subnet[count.index].availability_zone}" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public[count.index].id
}

## NAT
resource "aws_nat_gateway" "ngw" {
  count         = local.count_with_nat
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  tags          = { Name = "nat-${aws_subnet.public_subnet[count.index].availability_zone}" }
}
