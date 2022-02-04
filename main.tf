provider "aws" {
  region     = "${var.region}"
}

resource "aws_key_pair" "web" {
  public_key    = "${file(pathexpand(var.public_key))}"
}

resource "aws_security_group" "web-instance-security-group" {
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #security_groups = ["${aws_security_group.bastion_sg.id}"]
    }
  
  # SSH Access from Bastion
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg_web"
  }

}

# Generate the template used to create the web server
  
resource "aws_launch_configuration" "web" {
    name_prefix             = "web-instance-"
    image_id                = "${data.aws_ami.ebs-linux.id}"
    instance_type           = "${var.instance_type}"
    key_name                = "${aws_key_pair.web.key_name}"
    security_groups         = [ "${aws_security_group.web-instance-security-group.id}","${aws_security_group.bastion-EC2-SSH.id}"]
    #associate_public_ip_address = true
    user_data               = <<EOF
  #!/bin/sh
  sudo yum update -y
  sleep 10
  sudo yum install -y nginx java-1.8.0-openjdk.x86_64
  sleep 10
  sudo service nginx start
  sudo sed -e 's/root/#: &/' /etc/nginx/nginx.conf
  sudo sed -i '/listen       80;/a location / { proxy_pass http://127.0.0.1:8080; }'  /etc/nginx/nginx.conf
  sudo mkdir -p /opt/java-app && wget -O /opt/java-app/demo-0.0.1-SNAPSHOT.jar https://github.com/sebwells/example-java-spring-boot-app/raw/master/demo-0.0.1-SNAPSHOT.jar
  sudo java8 -jar /opt/java-app/demo-0.0.1-SNAPSHOT.jar &
  sudo service nginx restart
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
    health_check_type       = "EC2"
    health_check_grace_period = 300
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
        "${aws_subnet.private-subnet.id}"
    ]

    lifecycle {
        create_before_destroy = true
    }

    tag {
        key                 = "Name"
        value               = "web-instance"
        propagate_at_launch = true
    }

}

