
resource "aws_security_group" "bastion" {
  name        = "Bastion"
  vpc_id      = "${aws_vpc.vpc.id}"

  # SSH Access from world
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
}

# Generate the template used to create the web server
resource "aws_launch_configuration" "web" {
    name_prefix             = "web-instance-"
    image_id                = "${data.aws_ami.ebs-linux.id}"
    instance_type           = "${var.instance_type}"
    key_name                = "${aws_key_pair.web.key_name}"
    security_groups         = [ "${aws_security_group.web-instance-security-group.id}" ]
    associate_public_ip_address = true
    user_data               = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF

  lifecycle {
    create_before_destroy = true
  }
}

#Launch the qty of server resources desired 
resource "aws_autoscaling_group" "web"{
    name                    = "${aws_launch_configuration.web.name}-asg"
    min_size                = 1
    desired_capacity        = 1
    max_size                = 2
    health_check_type       = "ELB"
    load_balancers          = ["${aws_elb.web-elb.id}" ]
    launch_configuration    = "${aws_launch_configuration.web.name}"
    enabled_metrics         = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
    ]

    metrics_granularity     = "1Minute"

    vpc_zone_identifier     = [
        "${aws_subnet.public-subnet.id}"
    ]

  # Required to redeploy without an outage.
    lifecycle {
        create_before_destroy = true
    }

    tag {
        key                 = "Name"
        value               = "web-instance"
        propagate_at_launch = true
  }

}
