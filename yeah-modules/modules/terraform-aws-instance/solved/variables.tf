variable "instance_name" {
    description = "Name for the AWS instance"
    type = string
}

variable "instance_type" {
  description = "Type for your instance. Defaults to t3.micro"
  type = string
  default = "t3.micro"
}