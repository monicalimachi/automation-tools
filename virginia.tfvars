region="us-east-1"
#Other option: Copied from eu-west-1: ami-0a176d9d7b597cc2c
vpc-cidr = "10.10.30.0/24"

# feel free to change this subnet cidr block if required
subnet-cidr-public = "10.10.30.0/27"

#ELB
instance_port="80"
lb_port="80"
instance_protocol="http"
lb_protocol="http"
health_check_target="HTTP:80/"
health_check_interval=30
health_check_timeout=3
associate_public_ip=true
sg_id=[""]
instance_type="t2.micro"
