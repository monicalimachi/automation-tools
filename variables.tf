variable "region" {}
variable "vpc-cidr" {}
variable "subnet-cidr-public" {}
variable "subnet-cidr-private" {}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  default = "t2.micro"
}
