resource "aws_security_group" "bastion_sg" {
  name        = "Bastion"
  vpc_id      = "${aws_vpc.vpc.id}"

  # SSH Access 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
      Name      = "bastion-sg-ssh"
  }
}

resource "aws_security_group" "bastion-EC2-SSH" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_launch_configuration" "bastion-lc" {
    name_prefix         = "bastion_config-"
    image_id            = "${data.aws_ami.ebs-linux.id}"
    instance_type       = "${var.instance_type}"
    key_name            = "${aws_key_pair.web.key_name}"
    security_groups     = [ "${aws_security_group.bastion_sg.id}", ]
    associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "bastion-asg"{
    name                    = "${aws_launch_configuration.bastion-lc.name}-asg"
    min_size                = 1
    desired_capacity        = 1
    max_size                = 2
    health_check_grace_period = 300
    health_check_type       = "EC2"
    force_delete            = true
    launch_configuration    = "${aws_launch_configuration.bastion-lc.name}"

    vpc_zone_identifier     = [
        "${aws_subnet.public-subnet.id}"
    ]

  # Required to redeploy without an outage.
    lifecycle {
        create_before_destroy = true
    }

    tag {
        key                 = "Name"
        value               = "bastion"
        propagate_at_launch = true
  }

}
