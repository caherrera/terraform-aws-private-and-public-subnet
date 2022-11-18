data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

### Public Subnet, Nat and Route Tables
resource "aws_subnet" "public_subnet" {
  count             = var.az_count
  cidr_block        = cidrsubnet(data.aws_vpc.main.cidr_block, 8, count.index + var.az_count + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = data.aws_vpc.main.id
  tags              = { Name = "Public ${data.aws_availability_zones.available.names[count.index]}" }
}

resource "aws_eip" "nat" {
  count = local.count_with_nat
  vpc   = true
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
