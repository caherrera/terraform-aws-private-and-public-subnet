output "private_subnet" {
  value = aws_subnet.private_subnet
}

output "database_subnet_group" {
  value = aws_db_subnet_group.private
}
output "public_subnet" {
  value = aws_subnet.public_subnet
}

output "vpc" {
  value = data.aws_vpc.main
}