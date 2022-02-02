variable "region" {}
variable "vpc-cidr" {}
variable "subnet-cidr-public" {}
# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_port" {
  default = "80"
}

variable "lb_port" {
  default = "80"
}

variable "lb_protocol" {}

variable "instance_protocol" {
  default = "http"
}

variable "health_check_target" {}

variable "internal" {
 default = true 
}

variable "health_check_interval" {
  default=30
}

variable "health_check_timeout" {
  default=3
}

variable "associate_public_ip" {
  default=true
}

variable "sg_id" {
 default = [""]
}

variable "key_name" {
  default = "MonicaLimachi"
}
variable "instance_type" {
  default = "t2.micro"
}
