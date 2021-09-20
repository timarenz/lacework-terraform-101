provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web" {
  ami           = "ami-091f21ecba031b39a"
  instance_type = "t3.micro"
  tags = {
    Name = "HelloVM"
  }
}