provider aws{
    region  =   "eu-west-1"
}

resource "aws_instance" "my-first-server"{
    ami             =   "ami-cdbfa4ab"
    instance_type   =   "t2.micro"
}