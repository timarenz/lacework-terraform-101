output "hello_instance_public_ip" {
  value = module.hello_instance.public_ip
}

output "hello_instance_nano_public_ip" {
  value = module.hello_instance_nano.public_ip
}