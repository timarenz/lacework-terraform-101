resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]

  tags = {
    Name = var.instance_name
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = tls_private_key.ssh.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "curl -sSL https://s3-us-west-2.amazonaws.com/www.lacework.net/download/4.2.0.218_2021-08-27_release-v4.2_918a6d2e7e45c361fce5e46d6f43134203be86ff/install.sh > /tmp/install.sh",
      "chmod +x /tmp/install.sh",
      "sudo /tmp/install.sh -U https://api.fra.lacework.net ${var.lacework_agent_token}",
      "rm -rf /tmp/lw-install.sh"
    ]
  }
}

resource "random_id" "id" {
  byte_length = 4
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "ssh" {
  key_name   = "${random_id.id.hex}-ssh"
  public_key = tls_private_key.ssh.public_key_openssh
  tags       = {}
}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_security_group" "allow_traffic" {
  name   = "${random_id.id.hex}-allow-traffic"
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

  egress = [{
    description      = "Lets talk to the world!"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
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
