### Private Subnet, Nat and Route Tables
locals {
  private_netnum_offset = coalesce(var.netnum_offset, var.private_netnum_offset )
  private_extra_offset  = var.netnum_offset !=null ? var.az_count : 0

}
resource "aws_subnet" "private_subnet" {
  count             = var.az_count
  cidr_block        = coalesce(var.private_cidr_block, cidrsubnet(data.aws_vpc.main.cidr_block, var.newbits, count.index + local.private_netnum_offset + local.private_extra_offset))
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = data.aws_vpc.main.id
  tags              = merge({
    Name = "Private ${data.aws_availability_zones.available.names[count.index]}"
  }, var.private_tags)
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