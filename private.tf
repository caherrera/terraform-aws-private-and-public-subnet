### Private Subnet, Nat and Route Tables
resource "aws_subnet" "private_subnet" {
  count             = var.az_count
  cidr_block        = coalesce(var.private_cidr_block, cidrsubnet(data.aws_vpc.main.cidr_block, var.newbits, count.index+var.netnum_offset))
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = data.aws_vpc.main.id
  tags              = { Name = "Private ${data.aws_availability_zones.available.names[count.index]}" }
}

resource "aws_db_subnet_group" "private" {
  name       = "private_subnet_group"
  subnet_ids = aws_subnet.private_subnet.*.id
}

resource "aws_route_table" "private" {
  count  = length(aws_nat_gateway.ngw)
  vpc_id = data.aws_vpc.main.id

  tags = { Name = "Private RT ${aws_subnet.private_subnet[count.index].availability_zone}" }

  route {
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
    cidr_block     = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_route_table.private)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}