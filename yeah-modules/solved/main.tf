provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-2"
}

module "hello_instance" {
  source        = "./modules/terraform-aws-instance"
  instance_name = "HelloInstance"
}

module "hello_instance_nano" {
  source        = "./modules/terraform-aws-instance"
  instance_name = "HelloInstanceNano"
  instance_type = "t3.nano"
}

module "hello_instance_us" {
  providers = {
    aws = aws.us
  }
  source        = "./modules/terraform-aws-instance"
  instance_name = "HelloInstanceUS"
}

resource "local_file" "hello_instance_ssh" {
  content         = module.hello_instance.ssh_private_key
  filename        = "${path.root}/hello-instance-ssh.key"
  file_permission = "0400"
}