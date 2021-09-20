# lacework-terraform-101 - modules

In the first section we learned how to use Terraform. Now we want to introduce the concept of modules.
Modules are basically a set of Terraform files in a single directory that allow you to allow you to reuse your code again and again.

Modules are often used to:
* Organize configurations
* Encapsulate configuration
* Re-use configuration
* Provide consistency and ensure best practices

More details can be found here: <https://learn.hashicorp.com/tutorials/terraform/module?in=terraform/modules>

## Create your first module

Well, you actually already did this by completing the first part of this 101 course.
By create your Terraform code and adding input varibales and outputs values you bascially created a module.
One small change and you can actually use it as a module.

So, lets do this. Copy the `.tf` files from the `hello-instance` in the directory `yeah-modules/modules/terraform-aws-instances`

As you can the last part of the folder structure actually has a very specific name `terraform-aws-instance`.
This is best practice and a module should ideally named in the format `terraform-<PROVIDER>-<NAME>`.

Provider, should be the main provider where your module creates infrastructure. In our case we only create infrastructure in AWS, for this reason we use `aws`.
And as we create an AWS instance with some additional configuration we simply choose `instance` as name.

And thats almost it: there is one best practice that a module should never contain provider specific configuration.
For this reason we need to remove the provider block and the variable we used to configure the default region.

Remove the following from the `main.tf`:

```hcl
provider "aws" {
  region = var.aws_default_region
}
```

And remove this from the `variables.tf`, leaving the file empty for now:

```hcl
variable "aws_default_region" {
  description = "If you want to change the default region to another region, use this variable. Examples could be us-west-2 or ap-north-1."
  type        = string
  default     = "eu-central-1"
}
```

We kept the `version.tf` file that specifies the required provider version for AWS. This is according to best practice as we want to make sure your module only is used with provider versions it is tested against.

## Use your first module

Now, that we created the module. We want to consume it.
For this create a new `main.tf` in the `yeah-modules` directory.
As per our definition at the beginning actually every Terraform workspace is more or less a module.
In Terraform definition the workspace containing the `main.tf` file consuming other modules is called a root module.

Within that rood module we configure the providers, in this case for AWS, and add our module.

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "hello_instance" {
    source = "./modules/terraform-aws-instance"
}
```

A module is definied by the type `module` followed by an customizable internal name, we just called it `hello_instance`.
There are different methods to source a module, while we used a local path you could also you also use S3 buckets, GitHub, generic git repots, the Terraform registry and more: <https://www.terraform.io/docs/language/modules/sources.html>. We will learn how to use GitHub/Git as a source later.

Now initialize this workspace using `terraform init`. As you can see not only the providers required are downloaded, but the module itself as will.
In fact, as we using module located in the file system it is only linked but not downloaded.

```bash
$ terraform init

Initializing modules...
- hello_instance in modules/terraform-aws-instance

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/tls...
- Finding latest version of hashicorp/local...
- Finding hashicorp/aws versions matching "3.59.0"...
- Installing hashicorp/local v2.1.0...
- Installed hashicorp/local v2.1.0 (signed by HashiCorp)
- Installing hashicorp/aws v3.59.0...
- Installed hashicorp/aws v3.59.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Installing hashicorp/tls v3.1.0...
- Installed hashicorp/tls v3.1.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Let's apply our configuration using `terraform apply`.

```bash
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.hello_instance.aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-091f21ecba031b39a"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "HelloVM"
        }
      + tags_all                             = {
          + "Name" = "HelloVM"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.hello_instance.aws_key_pair.ssh will be created
  + resource "aws_key_pair" "ssh" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = (known after apply)
      + key_pair_id = (known after apply)
      + public_key  = (known after apply)
      + tags_all    = (known after apply)
    }

  # module.hello_instance.aws_security_group.allow_ssh will be created
  + resource "aws_security_group" "allow_ssh" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "SSH from 0.0.0.0/0"
              + from_port        = 22
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = (known after apply)
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = "vpc-70f8d919"
    }

  # module.hello_instance.local_file.ssh will be created
  + resource "local_file" "ssh" {
      + content              = (sensitive)
      + directory_permission = "0777"
      + file_permission      = "0400"
      + filename             = "./ssh.key"
      + id                   = (known after apply)
    }

  # module.hello_instance.random_id.id will be created
  + resource "random_id" "id" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # module.hello_instance.tls_private_key.ssh will be created
  + resource "tls_private_key" "ssh" {
      + algorithm                  = "RSA"
      + ecdsa_curve                = "P224"
      + id                         = (known after apply)
      + private_key_pem            = (sensitive value)
      + public_key_fingerprint_md5 = (known after apply)
      + public_key_openssh         = (known after apply)
      + public_key_pem             = (known after apply)
      + rsa_bits                   = 4096
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.hello_instance.tls_private_key.ssh: Creating...
module.hello_instance.random_id.id: Creating...
module.hello_instance.random_id.id: Creation complete after 0s [id=JHHXSg]
module.hello_instance.aws_security_group.allow_ssh: Creating...
module.hello_instance.aws_security_group.allow_ssh: Creation complete after 1s [id=sg-04cc090064e860508]
module.hello_instance.tls_private_key.ssh: Creation complete after 3s [id=abd09ee5b4f39a30ef0bd81d0037a6bcc0340e5c]
module.hello_instance.aws_key_pair.ssh: Creating...
module.hello_instance.local_file.ssh: Creating...
module.hello_instance.local_file.ssh: Creation complete after 0s [id=682fc0381b5f07a532163b9ae27f55139f98ef41]
module.hello_instance.aws_key_pair.ssh: Creation complete after 0s [id=2471d74a-ssh]
module.hello_instance.aws_instance.web: Creating...
module.hello_instance.aws_instance.web: Still creating... [10s elapsed]
module.hello_instance.aws_instance.web: Creation complete after 12s [id=i-05b369260b8a600ee]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

As you can see a lot of stuff is happening, even though in our root module we only have a couple of lines of code.
Now that the instance is created, what is missing is the output of the public IP address.

## Getting outputs

To get an output we actually need to take an output of the child module `hello_instance` and use it as output in our root module our Terraform workspace.

For this we first create a `outputs.tf` file and add the following code:

```hcl
output "hello_instance_public_ip" {
  value = module.hello_instance.public_ip
}
```

As you can see we just declared a normal output and as value of the output we can actually use all outputs that are defined within the child module.
To address the output of a module use the following syntax: `module.<MODULENAME>.<OUTPUTNAME>` in our case `module.hello_instance.public_ip`.

No, if you apply this configuration using `terraform apply` you should see the public IP address as output.

```bash
$ terraform apply

module.hello_instance.tls_private_key.ssh: Refreshing state... [id=abd09ee5b4f39a30ef0bd81d0037a6bcc0340e5c]
module.hello_instance.random_id.id: Refreshing state... [id=JHHXSg]
module.hello_instance.local_file.ssh: Refreshing state... [id=682fc0381b5f07a532163b9ae27f55139f98ef41]
module.hello_instance.aws_key_pair.ssh: Refreshing state... [id=2471d74a-ssh]
module.hello_instance.aws_security_group.allow_ssh: Refreshing state... [id=sg-04cc090064e860508]
module.hello_instance.aws_instance.web: Refreshing state... [id=i-05b369260b8a600ee]

Changes to Outputs:
  + hello_instance_public_ip = "3.70.2.80"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

hello_instance_public_ip = "3.70.2.80"
```

We now have an output as we know it and can use it in the same way.
Actually, we also got an additional output that was created - the ssh.key file.

The reason for this is that we actually used a special path `${path.root}` within the code for the `local_file` resource.

```hcl
resource "local_file" "ssh" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.root}/ssh.key"
  file_permission = "0400"
}
```

This actually links to the path of the root module, our current working directory. If you want to have this child created in the working directory of the child module (in our case `./modules/terraform-aws-instance`) you would need to change the variable to `$(path.module)`. However, this doesn't make much sense as we don't want to search child modules for SSH keys.
A better idea would be to give back the SSH key as output and not save it directly as file.

Another big benefit of this would be that I can now use my module multiple times without overwriting the same file.

## Optimize your module for re-use - starting with outputs

Besides optimizing output it might also make sense to add some user inputs to the module, for example, possibility to set a customer instance name.

Lets start moving the SSH key from a file output to an output value. For that open the `modules/terraform-aws-instance/main.tf` and `modules/terraform-aws-instance/outputs.tf`

Add a new output called `ssh_private_key` to your `outputs.tf`:

```hcl
output "ssh_private_key" {
  value = tls_private_key.ssh.private_key_pem
  sensitive = true
}
```

We can actually just copy and paste the value from the `local_file` content argument. Also we set the argument `sensitive = true`as the output is actually a SSH private key and should not be printed as output on the command line. For more details around sensitive outputs, see <https://www.terraform.io/docs/language/values/variables.html#suppressing-values-in-cli-output>.

To complete this refactor, we need to remove the `local_file` resource in the `main.tf`. Actually, you can copy and paste it over to your root module and use the newly create output of the child module called `ssh_private_key` as input of the `local_file` resource in you root module.

So, cut the following code from the `modules/terraform-aws-instance/main.tf`.

```hcl
resource "local_file" "ssh" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.root}/ssh.key"
  file_permission = "0400"
}
```

And paste it to your `main.tf` in the root module, but slightly modified:

```hcl
resource "local_file" "hello_instance_ssh" {
  content         = module.hello_instance.ssh_private_key
  filename        = "${path.root}/hello-instance-ssh.key"
  file_permission = "0400"
}
```
For cosmetic reasons we changed the resource and file name, but most importantly we changed the value of `content` to newly added output from our module `module.hello_instance.ssh_private_key`.

Now, if you apply the configuration using `terraform apply` the old file `ssh.key` will be deleted and the new file `hello-instance-ssh.key` will be created.

```bash
$ terraform apply

module.hello_instance.local_file.ssh: Refreshing state... [id=682fc0381b5f07a532163b9ae27f55139f98ef41]
module.hello_instance.random_id.id: Refreshing state... [id=JHHXSg]
module.hello_instance.tls_private_key.ssh: Refreshing state... [id=abd09ee5b4f39a30ef0bd81d0037a6bcc0340e5c]
module.hello_instance.aws_key_pair.ssh: Refreshing state... [id=2471d74a-ssh]
module.hello_instance.aws_security_group.allow_ssh: Refreshing state... [id=sg-04cc090064e860508]
module.hello_instance.aws_instance.web: Refreshing state... [id=i-05b369260b8a600ee]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # local_file.hello_instance_ssh will be created
  + resource "local_file" "hello_instance_ssh" {
      + content              = (sensitive)
      + directory_permission = "0777"
      + file_permission      = "0400"
      + filename             = "./hello-instance-ssh.key"
      + id                   = (known after apply)
    }

  # module.hello_instance.local_file.ssh will be destroyed
  - resource "local_file" "ssh" {
      - content              = (sensitive) -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0400" -> null
      - filename             = "./ssh.key" -> null
      - id                   = "682fc0381b5f07a532163b9ae27f55139f98ef41" -> null
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.hello_instance.local_file.ssh: Destroying... [id=682fc0381b5f07a532163b9ae27f55139f98ef41]
module.hello_instance.local_file.ssh: Destruction complete after 0s
local_file.hello_instance_ssh: Creating...
local_file.hello_instance_ssh: Creation complete after 0s [id=682fc0381b5f07a532163b9ae27f55139f98ef41]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

hello_instance_public_ip = "3.70.2.80"
```

## Optimize for re-use - users choice

While we already use random names in our module using the `random_id` resource we set a static value for the name tag called `HelloInstance`

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "HelloInstance"
  }
}
```

Same goes for the `instance_type`. Lets give the users choice and let them choose a name tag and also let them change the instance type while providing `t3.micro` as default value.
We need to add two new input variables for this in `modules/terraform-aws-instance/variables.tf` file.

```hcl
variable "instance_name" {
    description = "Name for the AWS instance"
    type = string
}

variable "instance_type" {
  description = "Type for your instance. Defaults to t3.micro"
  type = string
  default = "t3.micro"
}
```

Those new varibales now need to be used as input for the configuration of your AWS instance in the `modules/terraform-aws-instance/variables.tf` file.

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = var.instance_name
  }
}
```

With those changes applied try to run `terraform apply`.

```bash
$ terraform apply

│ Error: Missing required argument
│
│   on main.tf line 5, in module "hello_instance":
│    5: module "hello_instance" {
│
│ The argument "instance_name" is required, but no definition was found.
```

As our module requires the `instance_name` and no default value is given, our `terraform apply` fails as this varibale is missing in our configuration.
Within the `main.tf` of our root module add the following:

```hcl
module "hello_instance" {
    source = "./modules/terraform-aws-instance"
    instance_name = "HelloInstance"
}
```

Re-run `terraform apply`. As we didn't change the name of the instance nor the type. No changes are applied.

```bash
$ terraform apply

module.hello_instance.tls_private_key.ssh: Refreshing state... [id=abd09ee5b4f39a30ef0bd81d0037a6bcc0340e5c]
module.hello_instance.random_id.id: Refreshing state... [id=JHHXSg]
local_file.hello_instance_ssh: Refreshing state... [id=682fc0381b5f07a532163b9ae27f55139f98ef41]
module.hello_instance.aws_key_pair.ssh: Refreshing state... [id=2471d74a-ssh]
module.hello_instance.aws_security_group.allow_ssh: Refreshing state... [id=sg-04cc090064e860508]
module.hello_instance.aws_instance.web: Refreshing state... [id=i-05b369260b8a600ee]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

hello_instance_public_ip = "3.70.2.80"
```

We now have a module that can reused as many times as we want. And thats what we will do right now.

## More instances, less code = green coding

To reuse the module we can simply copy and paste the code we used in the `maint.tf` file and change it slighty.

```hcl
module "hello_instance" {
    source = "./modules/terraform-aws-instance"
    instance_name = "HelloInstance"
}

module "hello_instance_nano" {
    source = "./modules/terraform-aws-instance"
    instance_name = "HelloInstanceNano"
    instance_type = "t3.nano"
}
```

The module name needs to be unique within our Terraform code in order to access the different outputs of the module so we called it `hello_instance_nano`.
We also changed the `instance_name` and `instance_type`.

We also want to add another output to get the public IP of the new instance. For this modify the `outputs.tf` like this:

```hcl
output "hello_instance_public_ip" {
  value = module.hello_instance.public_ip
}

output "hello_instance_nano_public_ip" {
  value = module.hello_instance_nano.public_ip
}
```

Before we can apply those changes we need to reinitialize our Terraform workspace, as we added a module and it needs to be "downloaded/cached" within our working directory.

```bash
$ terraform init

Initializing modules...
- hello_instance_nano in modules/terraform-aws-instance

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/tls from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Using previously-installed hashicorp/aws v3.59.0
- Using previously-installed hashicorp/random v3.1.0
- Using previously-installed hashicorp/tls v3.1.0
- Using previously-installed hashicorp/local v2.1.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Now that we initialized the "new" module, lets apply our changes by running `terraform apply`.

```bash
module.hello_instance.tls_private_key.ssh: Refreshing state... [id=abd09ee5b4f39a30ef0bd81d0037a6bcc0340e5c]
module.hello_instance.random_id.id: Refreshing state... [id=JHHXSg]
local_file.hello_instance_ssh: Refreshing state... [id=682fc0381b5f07a532163b9ae27f55139f98ef41]
module.hello_instance.aws_key_pair.ssh: Refreshing state... [id=2471d74a-ssh]
module.hello_instance.aws_security_group.allow_ssh: Refreshing state... [id=sg-04cc090064e860508]
module.hello_instance.aws_instance.web: Refreshing state... [id=i-05b369260b8a600ee]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.hello_instance_nano.aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-091f21ecba031b39a"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "HelloInstance"
        }
      + tags_all                             = {
          + "Name" = "HelloInstance"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.hello_instance_nano.aws_key_pair.ssh will be created
  + resource "aws_key_pair" "ssh" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = (known after apply)
      + key_pair_id = (known after apply)
      + public_key  = (known after apply)
      + tags_all    = (known after apply)
    }

  # module.hello_instance_nano.aws_security_group.allow_ssh will be created
  + resource "aws_security_group" "allow_ssh" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "SSH from 0.0.0.0/0"
              + from_port        = 22
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = (known after apply)
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = "vpc-70f8d919"
    }

  # module.hello_instance_nano.random_id.id will be created
  + resource "random_id" "id" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # module.hello_instance_nano.tls_private_key.ssh will be created
  + resource "tls_private_key" "ssh" {
      + algorithm                  = "RSA"
      + ecdsa_curve                = "P224"
      + id                         = (known after apply)
      + private_key_pem            = (sensitive value)
      + public_key_fingerprint_md5 = (known after apply)
      + public_key_openssh         = (known after apply)
      + public_key_pem             = (known after apply)
      + rsa_bits                   = 4096
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + hello_instance_nano_public_ip = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.hello_instance_nano.random_id.id: Creating...
module.hello_instance_nano.tls_private_key.ssh: Creating...
module.hello_instance_nano.random_id.id: Creation complete after 0s [id=vTKGvw]
module.hello_instance_nano.aws_security_group.allow_ssh: Creating...
module.hello_instance_nano.aws_security_group.allow_ssh: Creation complete after 1s [id=sg-0a924ec35dabd1358]
module.hello_instance_nano.tls_private_key.ssh: Creation complete after 2s [id=f859dd247efea5d36cbbe3bca1e3b5a6c248b325]
module.hello_instance_nano.aws_key_pair.ssh: Creating...
module.hello_instance_nano.aws_key_pair.ssh: Creation complete after 0s [id=bd3286bf-ssh]
module.hello_instance_nano.aws_instance.web: Creating...
module.hello_instance_nano.aws_instance.web: Still creating... [10s elapsed]
module.hello_instance_nano.aws_instance.web: Creation complete after 13s [id=i-066f4b25896c7f84d]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

hello_instance_nano_public_ip = "3.68.233.132"
hello_instance_public_ip = "3.70.2.80"
```

As you can see we now have two instance and also get two public IP adresses. We didn't add another `local_file` resource to create a new SSH private key file for the "nano" instance.

## Go multi-cloud light, using another AWS region

Sometimes you want to use the same module but, for example, in different regions.
In our case we want to deploy a third instance in `us-east-2`.

For this we do not need to chance anything in our module. It is purley a configuration done in our root module.

First, we need add another AWS provider with a different region. As we can not configure a provider with the same name more than once we need to set up a provider alias, also see: <https://www.terraform.io/docs/language/providers/configuration.html#alias-multiple-provider-configurations>.

An alias can be configured like the follows in the `main.tf` file.

```hcl
provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias = "us"
  region = "us-east-2"
}
```

We have added another AWS provider with the region `us-east-2` with the alias `us`. This can be referenced within your modules as `aws.usa`.
To use this provider inside a module, we have to specifcy provider within the module defintion in our root module.

```hcl
module "hello_instance" {
    source = "./modules/terraform-aws-instance"
    instance_name = "HelloInstance"
}

module "hello_instance_nano" {
    source = "./modules/terraform-aws-instance"
    instance_name = "HelloInstanceNano"
    instance_type = "t3.nano"
}

module "hello_instance_us" {
    providers = {
      aws = aws.us
    }
    source = "./modules/terraform-aws-instance"
    instance_name = "HelloInstanceUS"
}
```

As you can see it is as simple as adding the provider argument with the value of the new provider alias `aws.us` to your module definiton.
With those changes put into your `main.tf` reinitalize your workspace using `terraform init` to load the new module and the apply the configuration using `terraform apply`.

```bash
Initializing modules...
$ terraform init

- hello_instance_us in modules/terraform-aws-instance

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/tls from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Using previously-installed hashicorp/aws v3.59.0
- Using previously-installed hashicorp/tls v3.1.0
- Using previously-installed hashicorp/random v3.1.0
- Using previously-installed hashicorp/local v2.1.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

$ terraform apply

module.hello_instance_nano.random_id.id: Refreshing state... [id=vTKGvw]
module.hello_instance.random_id.id: Refreshing state... [id=JHHXSg]
module.hello_instance.tls_private_key.ssh: Refreshing state... [id=abd09ee5b4f39a30ef0bd81d0037a6bcc0340e5c]
module.hello_instance_nano.tls_private_key.ssh: Refreshing state... [id=f859dd247efea5d36cbbe3bca1e3b5a6c248b325]
local_file.hello_instance_ssh: Refreshing state... [id=682fc0381b5f07a532163b9ae27f55139f98ef41]
module.hello_instance_nano.aws_key_pair.ssh: Refreshing state... [id=bd3286bf-ssh]
module.hello_instance.aws_key_pair.ssh: Refreshing state... [id=2471d74a-ssh]
module.hello_instance_nano.aws_security_group.allow_ssh: Refreshing state... [id=sg-0a924ec35dabd1358]
module.hello_instance.aws_security_group.allow_ssh: Refreshing state... [id=sg-04cc090064e860508]
module.hello_instance.aws_instance.web: Refreshing state... [id=i-05b369260b8a600ee]
module.hello_instance_nano.aws_instance.web: Refreshing state... [id=i-066f4b25896c7f84d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.hello_instance_us.aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-0a5a9780e8617afe7"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "HelloInstance"
        }
      + tags_all                             = {
          + "Name" = "HelloInstance"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.hello_instance_us.aws_key_pair.ssh will be created
  + resource "aws_key_pair" "ssh" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = (known after apply)
      + key_pair_id = (known after apply)
      + public_key  = (known after apply)
      + tags_all    = (known after apply)
    }

  # module.hello_instance_us.aws_security_group.allow_ssh will be created
  + resource "aws_security_group" "allow_ssh" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "SSH from 0.0.0.0/0"
              + from_port        = 22
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = (known after apply)
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = "vpc-b0c2aad9"
    }

  # module.hello_instance_us.random_id.id will be created
  + resource "random_id" "id" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # module.hello_instance_us.tls_private_key.ssh will be created
  + resource "tls_private_key" "ssh" {
      + algorithm                  = "RSA"
      + ecdsa_curve                = "P224"
      + id                         = (known after apply)
      + private_key_pem            = (sensitive value)
      + public_key_fingerprint_md5 = (known after apply)
      + public_key_openssh         = (known after apply)
      + public_key_pem             = (known after apply)
      + rsa_bits                   = 4096
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.hello_instance_us.tls_private_key.ssh: Creating...
module.hello_instance_us.random_id.id: Creating...
module.hello_instance_us.random_id.id: Creation complete after 0s [id=sDJq5Q]
module.hello_instance_us.aws_security_group.allow_ssh: Creating...
module.hello_instance_us.tls_private_key.ssh: Creation complete after 3s [id=43a5d8d125770271663cb8da1933c46839bfd80b]
module.hello_instance_us.aws_key_pair.ssh: Creating...
module.hello_instance_us.aws_key_pair.ssh: Creation complete after 1s [id=b0326ae5-ssh]
module.hello_instance_us.aws_security_group.allow_ssh: Creation complete after 4s [id=sg-0abf2ec02f7fead48]
module.hello_instance_us.aws_instance.web: Creating...
module.hello_instance_us.aws_instance.web: Still creating... [10s elapsed]
module.hello_instance_us.aws_instance.web: Creation complete after 17s [id=i-0b6621f1fcc673e5c]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

hello_instance_nano_public_ip = "3.68.233.132"
hello_instance_public_ip = "3.70.2.80"
```

A new instance is created in the AWS region `us-east-2`. We haven't configured any output to spare you the redundant work.

## Destroy and finished

To finish this section go and destroy the instances we have deployed.
By now you should know what to do.

Hint: `terraform destroy -auto-approve`

## Whats next

Before we dive into the Lacework Terraform modules below you will find some additional likes to learn more about modules:

* Module dependecies: <https://www.terraform.io/docs/language/meta-arguments/depends_on.html>
* DRY with modules
  * Count: <https://www.terraform.io/docs/language/meta-arguments/count.html>
  * For-each: <https://www.terraform.io/docs/language/meta-arguments/for_each.html>
* Development best practices: <https://www.terraform.io/docs/language/modules/develop/index.html>
* More interactive tutorials on HashiCorp Learn: <https://learn.hashicorp.com/collections/terraform/modules>