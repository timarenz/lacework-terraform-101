resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "HelloInstance"
  }
}

resource "random_id" "id" {
  byte_length = 4
}

resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  rsa_bits = "4096"
}

resource "aws_key_pair" "ssh" {
  key_name   = "${random_id.id.hex}-ssh"
  public_key = tls_private_key.ssh.public_key_openssh
  tags = {}
}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_security_group" "allow_ssh" {
  name   = "${random_id.id.hex}-allow-ssh"
  vpc_id = data.aws_vpc.selected.id

  ingress = [{
    description      = "SSH from 0.0.0.0/0"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
  tags = {}
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}