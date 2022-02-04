resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true
  instance_tenancy     = "default"
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-public}"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch= true
}

resource "aws_route_table" "public-subnet-route-table" {
  vpc_id         = "${aws_vpc.vpc.id}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id         = "${aws_vpc.vpc.id}"
}

resource "aws_route" "public-subnet-route" {
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.igw.id}"
  route_table_id          = "${aws_route_table.public-subnet-route-table.id}"
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id         = "${aws_subnet.public-subnet.id}"
  route_table_id    = "${aws_route_table.public-subnet-route-table.id}"
}

resource "aws_subnet" "private-subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet-cidr-private}"
  availability_zone       = "${var.region}b"
  #map_public_ip_on_launch = true

}

resource "aws_eip" "nat_eip" {
    vpc     = true
}

resource "aws_nat_gateway" "nat_igw"{
    allocation_id   = "${aws_eip.nat_eip.id}"
    #connectivity_type = private
    subnet_id       = "${aws_subnet.public-subnet.id}"
    tags ={
        Name    = "igw NAT"
    }
}

resource "aws_route_table" "private-subnet-route-table" {
  vpc_id         = "${aws_vpc.vpc.id}"
}

resource "aws_route" "private-subnet-route" {
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = "${aws_nat_gateway.nat_igw.id}"
  route_table_id          = "${aws_route_table.private-subnet-route-table.id}"
}

resource "aws_route_table_association" "nat_private" {
  subnet_id           = "${aws_subnet.private-subnet.id}"
  route_table_id      = "${aws_route_table.private-subnet-route-table.id}"
}

