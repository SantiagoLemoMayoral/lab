resource "aws_vpc" "main" {
   cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.1/24"
}

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.2/24"
}

resource "aws_subnet" "private_1" {
   vpc_id = aws_vpc.main.id
   cidr_block = "10.0.0.1/24"
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.2/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "eip1" {
  domain = "vpc"
}

resource "aws_eip" "eip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "first" {
  allocation_id = aws_eip.eip1.id
  subnet_id = aws_subnet.public_1.id
}

resource "aws_nat_gateway" "second" { 
  allocation_id = aws_eip.eip2.id
  subnet_id = aws_subnet.public_2.id
}

resource "aws_route_table" "first" {
  vpc_id = aws_vpc.main

  route{
    cidr_block = ""
    subnet_id = aws_subnet.public_1.id
  }
}

resource "aws_route_table" "second" {
  vpc_id = aws_vpc.main

  route{
    cidr_block = ""
    subnet_id = aws_subnet.public_1.id
  }
}

resource "aws_route_table" "third" {
  vpc_id = aws_vpc.main

  route{
    cidr_block = ""
    subnet_id = aws_subnet.public_1.id
  }
}

resource "aws_route_table" "fourth" {
  vpc_id = aws_vpc.main

  route{
    cidr_block = ""
    subnet_id = aws_subnet.public_1.id
  }
}

