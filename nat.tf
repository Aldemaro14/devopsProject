resource "aws_eip" "vpc_nat" {
    vpc = true
}

resource "aws_nat_gateway" "vpc_nat_gw" {
    allocation_id = aws_eip.vpc_nat.id
    subnet_id = aws_subnet.public_vpc1.id
    depends_on = [
      aws_internet_gateway.vpc_gw
    ]
}

resource "aws_route_table" "vpc_private" {

    vpc_id = aws_vpc.testvpc.id
    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.vpc_nat_gw.id
    }
    tags = {
        Name = "vpc_private"
    }
}

# Route Association Private
resource "aws_route_table_association" "vpc_private_1a" {
    subnet_id = aws_subnet.private_vpc1.id
    route_table_id = aws_route_table.vpc_private.id
}