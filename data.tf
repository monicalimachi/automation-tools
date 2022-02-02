
#Get the image desired 
data "aws_ami" "ebs-linux" {
    most_recent         = true

  filter {
    name                = "name"
    values              = ["amzn-ami-hvm-2017.03.1.20170623-x86_64-ebs*"]
  }

  filter {
    name                = "virtualization-type"
    values              = ["hvm"]
  }

    owners              = ["amazon"] 
}