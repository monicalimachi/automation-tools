provider "aws" {
  region     = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true
  
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-public}"
  availability_zone = "${var.region}a"
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


resource "aws_security_group" "web-instance-security-group" {
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags{
      Name      = "ssh-allowed"
  }
}

resource "aws_security_group" "elb" {
  name    = "elb"
  vpc_id  = "${aws_vpc.vpc.id}"
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "web" {
  public_key    = "${file(pathexpand(var.public_key))}"
}


resource "aws_elb" "web-elb"{
  name          = "web-elb"

  subnets                     = ["${aws_subnet.public-subnet.id}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  #internal="${var.internal}"

  listener { 
    
      instance_port     = "${var.instance_port}"
      instance_protocol = "${var.instance_protocol}"
      lb_port           = "${var.lb_port}"
      lb_protocol       = "${var.lb_protocol}"
    
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "${var.health_check_timeout}"
    target              = "${var.health_check_target}"
    interval            = "${var.health_check_interval}"
  }

  
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}


output "elb_dns_name" {
  value   = "${aws_elb.web-elb.dns_name}"
}