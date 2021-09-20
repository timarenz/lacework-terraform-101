# lacework-terraform-101

Terraform is an open-source infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. This includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc. Terraform can manage both existing service providers and custom in-house solutions.

In short it is:
* Executable documentation
* Human and machine readable
* Easy to learn

Terraform is the defacto standard for provisioning and configuring services within the cloud spaces. As of today there are 185 official and verified providers (vendors) that support Terraform.
Besides the big players like Amazon, Google and Microsoft there are providers for Kubernetes, GitHub, NewRelic and of course Lacework.

## Prep your environment

To get started with Terraform I highly recommend the following working environment:

* Terraform 1.0 CLI or later: <https://learn.hashicorp.com/tutorials/terraform/install-cli>
* Visual Studio Code: <https://code.visualstudio.com>
* HashiCorp Terraform Visual Studio Code extension: <https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform>

I would recommend storing your code in a git repo for versioning and maybe adding some actions for testing your code: <https://github.com/marketplace/actions/hashicorp-setup-terraform>

In addition please make sure you have configured your AWS credential either as [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) or as [configuration file using AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

And last but not leased, clone this repo: `git clone https://github.com/timarenz/lacework-terraform-101.git`

## Structure your first Terraform workspace

A folder that contains your Terraform files (*.tf) is called a Terraform workspaces. 
As best practice your workspace contains the following files:

* main.tf (by default this contains all your resources and provider configuration blocks.)
* variables.tf (To variablize your Terraform code this file stores all variables.)
* outputs.tf (You often have to output specific information (like IP adresses, URL, IDs, etc) to use in another workspace. This is the file to create those.)
* versions.tf (In general it is a best practice to specify versions of Terraform and providers used within your Terraform workspace, this is the file to do so. Fore more details, see <https://www.terraform.io/docs/language/providers/requirements.html>)

While those files are per best practice it is no need to create them. You can actually also just create one large file called `makelifeharder.tf` and put all your Terraform code in it.
The Terraform CLI takes whatever `.tf` files you have in your workspace and uses them.
While it makes sense to align to the best practices shown above, it sometimes makes sense to have additional files to not end up with a massive `main.tf` and instead move specific parts of code (may resource related) to different files.
For example, having a `security-groups.tf` or `servers.tf` or the like.

## Your first Terraform code, the Hello Instance example

By now, you probaly ask yourself what are providers, resource and so on in Terraform? We will cover this now by deploying our first resource, an ec2 instance.
In the folder `hello-instance` all files just mentioned are prepped for you.

Lets first have a look at the `main.tf` file.

```hcl
provider "aws" {
  region = "eu-central-1"
}


resource "aws_instance" "web" {
  ami           = "ami-091f21ecba031b39a"
  instance_type = "t3.micro"
  tags = {
    Name = "HelloInstance"
  }
}
```

### provider block

For almost all systems you want to configure using Terraform you need to configure a provider.
Make sure to NEVER store your secrets (access keys, etc) in your Terraform code.
Most providers support sourcing secrets from the runtime environment by using configuration files or environment variables.
See this example from AWS: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication>

There are roughly 1400 providers available as of today, so you basically can configure evertyhing you can image with Terraform.
The Terraform registry is the place to find providers and documentation: <https://registry.terraform.io/browse/providers>

In our example we hard-coded the AWS region to `eu-central-1` using the region argument.

### resource block

The `aws_instance` our first resource. It always structured the same way:

resource = top level keyword, identified the type for Terraform
type = Type of resource, for example, aws_instance or lacework_integration_aws_cfg for Lacework.
name = In this case "web", this is a Terraform internal name that you use as a reference. Its not the name within resource that is created. For example, the name of the VM.

And then you have (sometimes hundrets) of arguments to configure the actual resources. 
Luckily, this is documented within the Terraform registry as well: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance>.

General information around the Terraform sytanx can also be found here: <https://www.terraform.io/docs/language/index.html>. (Highly recommeded read!)

## Initialize your workspace

To deploy your first resource, an ec2 instance, we now need to initialize our workspace and then apply our Terraform configuration.
To do so run the `terraform init` in the directory that contains your file file. What will happen here is that Terraform looks at your code and idenitfizies what providers and modules (we will cover this later) will be required.
All required providers and modules will be downloaded and cached into your workspace.

Run `terraform init` now. After your initilized your workspace try to apply your first Terraform configuration.

```bash
$ terraform init                                                                                                                             

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "3.59.0"...
- Installing hashicorp/aws v3.59.0...
- Installed hashicorp/aws v3.59.0 (signed by HashiCorp)

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

## Apply your Terraform code

Now that your workspace is initialized we want to apply our Terraform code and as a result we should deploy a VM on AWS.
To do so run `terraform apply` in your workspace. Terraform apply create an 'execution plan' (more on this in a second) that then is directly applied.
You can also only run a `terraform plan` to do a dry-run without actually changing anything. 

For this make sure you have configured your AWS credentials using environmnet varibales or the credentials files created by AWS CLI: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication

```bash
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-091f21ecba031b39a"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      [...]
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

What Terraform is doing now, is to create first a so called plan. Simply put, this plan compares the Terraform code with the real world to understand if a resources needs to be added, changed or destroyed.
The plan can be used within your deployment pipeline, for example as a pull request comment before approval, to validate if the change you are about to apply is really what you want or if there is some error.

If not already done so approve the plan by typing yes and let Terrform do its magic.

```bash
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Creation complete after 12s [id=i-049d77327c09c3665]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

You did it, you just created your first resource in AWS. But, what now? How do I access this instance? What IP did it get assigned?

## Adding some output

In order to connect to the instance you need to get the public IP of it. Terraform allows you to output virtually any attribute or argument of resource and data sources (teaser!).
To output the public IP we configure a new output in the `outputs.tf`. Just copy and paste the code below.

```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}
```

The keyword `output`is just another type within Terraform, just as `resouce` itself. We named that output `public_ip` and as a `value` we use the `public_ip` attribute of our `aws_instance` resource with the internal name of `web`.
As a reminder, all attributes that can be accessed are documented in the provider documentation: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#attributes-reference>

Now, run `terraform apply` again to apply the changes to your code.

```hcl
$ terraform apply

aws_instance.web: Refreshing state... [id=i-049d77327c09c3665]

Changes to Outputs:
  + public_ip = "3.69.250.172"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

public_ip = "3.69.250.172"
```

We just added an output and now get the output displayed.
To learn more about outputs have a look at the Terraform docs: <https://www.terraform.io/docs/language/values/outputs.html>
There you will learn additional options like adding descriptions or make an output sensitive.

And while we now have the public IP address we still can not connect, because we don't have an SSH key for that.

## New resources, creating implicit dependencies and more stuff that sounds hard but is actually easy

To actually be able to acess the instance we created using SSH we not only need to somehow deploy a SSH key but also allow SSH access TCP port 22 to this specific instance.
And we will do this in two steps, first we will dynamically create a new unique SSH key-pair, add this key pair to AWS and assign in to your instance.

Below you will find the code to generate and SSH key pair and add it to AWS.

```hcl
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
```

We need to create a random ID because a key pair in AWS need to have an unique key name, for this we use the `random_id`resource.
While this uses a new provider called `random`, no additional provider block is requied as this provider doesn't need any configuration.

Second, we create a new TLS key pair using the `tls_private_key`resource out of the `tls`provider. Again, now provider block is required.

Last, we create the actual AWS key pair and we use the attribues that are outputed by the resources `random_id` and tls_private_key as inputs for this new resource.
You can see different styles of using those outputs, for `key_name` we actually use the output of the `random_id` resource as port af the string. For this reasing we need to use interpolation.
This bascially means put `${ ... }` around the variable.
The `public_key` attribute actually uses the direct output of the `tls_private_key` as input. So, no interpolation is requied.

Gernerally speaking, resources are always adressed in the following pattern: type.name.attribute in our case this is `tls_private_key.ssh.public_key_openssh` and `random_id.id.hex`. More details on references can be found here: <https://www.terraform.io/docs/language/expressions/references.html>
Those attributes are documented in the respective documentations: <https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#attributes-reference> and <https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id#read-only>.

Copy the code above to your `main.tf` file. You can just add it to the end of file. Terraform doesn't need any specific order.
During each `terraform apply` or `terraform plan` Terraform builds a dependency graph (kind of like a polygraph for Infrastructure-as-Code resources).
It is using implicit depedency (like we create using the outputs of resources as inputs of other resources) and explicit depedency using the `depends_on` meta-argument (we will not cover this, but more details can be found here: <https://www.terraform.io/docs/language/meta-arguments/depends_on.html>) to understand in what order resources need to be created and if operations can be run in parallel (if no dependencies exist).

You can actually visualize the graph using the `graph` command: https://www.terraform.io/docs/cli/commands/graph.html or use tools like blast-radius <https://github.com/28mm/blast-radius>.

Before finally applying our code, we need to re-initialize our Terraform workspace to download the new providers `random`and `tls`.

Please run `terraform init` and `terraform apply`

```bash
$ terraform init


Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/tls...
- Installing hashicorp/tls v3.1.0...
- Installed hashicorp/tls v3.1.0 (signed by HashiCorp)
- Using previously-installed hashicorp/aws v3.59.0
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

$ terraform apply

aws_instance.web: Refreshing state... [id=i-049d77327c09c3665]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.ssh will be created
  + resource "aws_key_pair" "ssh" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = (known after apply)
      + key_pair_id = (known after apply)
      + public_key  = (known after apply)
      + tags_all    = (known after apply)
    }

  # random_id.id will be created
  + resource "random_id" "id" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # tls_private_key.ssh will be created
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

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

tls_private_key.ssh: Creating...
random_id.id: Creating...
random_id.id: Creation complete after 0s [id=3uY-DQ]
tls_private_key.ssh: Creation complete after 2s [id=89556c7fb256835192af03afacf600f42c8360d1]
aws_key_pair.ssh: Creating...
aws_key_pair.ssh: Creation complete after 0s [id=dee63e0d-ssh]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

public_ip = "3.69.250.172"
```

## Changing the state of the AWS instance by adding the key pair

Terraform is using a state file (by default saved in our workspace as a file called `terraform.tfstate`) to save it's own view of the world.
It is using this file to compare your Terraform code, the state file itself and the real-world resources to understand what operation (add, update, destroy) needs to be used.

As you can see from our last output we didn't change anything on our `aws_instance.web` resource, so it wasn't touched by Terraform.
Terraform knew this from comparing your code, the state file and the real-world status of the resource.

The state file is highly importand and you should not delete it by any chance. For example, if you created resources using Terraform and delete the state file you will not be able to apply any chances to the resources that are created.

Now, that we created the AWS key pair we need to attach it to our instance. We just need to add the `key_name = aws_key_pair.ssh.key_name` argument to our `aws_instance.web` resource.
Again, you will find all arguments in the offical documentation: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#key_name>

```hcl
resource "aws_instance" "web" {
  ami           = "ami-091f21ecba031b39a"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.ssh.key_name
  tags = {
    Name = "HelloVM"
  }
}
```

Now, that you did your first inline edit (and hopefully did not just copy and paste everything) we need to make sure our code is properly formated and validated.
For this, Terraform offers to very helpful commands:

* `terraform fmt` to format your code. Even though, Visual Studio Code does a very good job here als long as you have the Terraform extension installed.
* `terraform validate` to actually check if the code is valid.

And now that you code is formatted and validated lets run a `terraform apply`

```hcl
tls_private_key.ssh: Refreshing state... [id=89556c7fb256835192af03afacf600f42c8360d1]
random_id.id: Refreshing state... [id=3uY-DQ]
aws_key_pair.ssh: Refreshing state... [id=dee63e0d-ssh]
aws_instance.web: Refreshing state... [id=i-049d77327c09c3665]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_instance.web must be replaced
-/+ resource "aws_instance" "web" {
      ~ arn                                  = "arn:aws:ec2:eu-central-1:382007176316:instance/i-049d77327c09c3665" -> (known after apply)
      ~ associate_public_ip_address          = true -> (known after apply)
      ~ availability_zone                    = "eu-central-1c" -> (known after apply)
      ~ cpu_core_count                       = 1 -> (known after apply)
      ~ cpu_threads_per_core                 = 2 -> (known after apply)
      ~ disable_api_termination              = false -> (known after apply)
      ~ ebs_optimized                        = false -> (known after apply)
      - hibernation                          = false -> null
      + host_id                              = (known after apply)
      ~ id                                   = "i-049d77327c09c3665" -> (known after apply)
      ~ instance_initiated_shutdown_behavior = "stop" -> (known after apply)
      ~ instance_state                       = "running" -> (known after apply)
      ~ ipv6_address_count                   = 0 -> (known after apply)
      ~ ipv6_addresses                       = [] -> (known after apply)
      + key_name                             = "dee63e0d-ssh" # forces replacement
      ~ monitoring                           = false -> (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      ~ primary_network_interface_id         = "eni-077b0a320968530dc" -> (known after apply)
      ~ private_dns                          = "ip-172-31-36-47.eu-central-1.compute.internal" -> (known after apply)
      ~ private_ip                           = "172.31.36.47" -> (known after apply)
      ~ public_dns                           = "ec2-3-69-250-172.eu-central-1.compute.amazonaws.com" -> (known after apply)
      ~ public_ip                            = "3.69.250.172" -> (known after apply)
      ~ secondary_private_ips                = [] -> (known after apply)
      ~ security_groups                      = [
          - "default",
        ] -> (known after apply)
      ~ subnet_id                            = "subnet-85c8e3cf" -> (known after apply)
        tags                                 = {
            "Name" = "HelloVM"
        }
      ~ tenancy                              = "default" -> (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      ~ vpc_security_group_ids               = [
          - "sg-43af6e2b",
        ] -> (known after apply)
        # (5 unchanged attributes hidden)

      ~ capacity_reservation_specification {
          ~ capacity_reservation_preference = "open" -> (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      - credit_specification {
          - cpu_credits = "unlimited" -> null
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

      ~ enclave_options {
          ~ enabled = false -> (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      ~ metadata_options {
          ~ http_endpoint               = "enabled" -> (known after apply)
          ~ http_put_response_hop_limit = 1 -> (known after apply)
          ~ http_tokens                 = "optional" -> (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      ~ root_block_device {
          ~ delete_on_termination = true -> (known after apply)
          ~ device_name           = "/dev/sda1" -> (known after apply)
          ~ encrypted             = false -> (known after apply)
          ~ iops                  = 100 -> (known after apply)
          + kms_key_id            = (known after apply)
          ~ tags                  = {} -> (known after apply)
          ~ throughput            = 0 -> (known after apply)
          ~ volume_id             = "vol-084da09f454def7de" -> (known after apply)
          ~ volume_size           = 8 -> (known after apply)
          ~ volume_type           = "gp2" -> (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ public_ip = "3.69.250.172" -> (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

In order to attach a new key pair to an AWS instance the instance actually needs to be redeployed.
This is actually catched by Terraform and it shows that it can not do an in-place upgrade but needs to replace the resource instead.
During this the output will also be changed, as we might get a new public IP address.

```hcl
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web: Destroying... [id=i-049d77327c09c3665]
aws_instance.web: Still destroying... [id=i-049d77327c09c3665, 10s elapsed]
aws_instance.web: Still destroying... [id=i-049d77327c09c3665, 20s elapsed]
aws_instance.web: Still destroying... [id=i-049d77327c09c3665, 30s elapsed]
aws_instance.web: Still destroying... [id=i-049d77327c09c3665, 40s elapsed]
aws_instance.web: Destruction complete after 50s
aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Creation complete after 12s [id=i-0c5413bca1e9443a0]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

public_ip = "3.123.29.247"
```

The AWS instance now has the new key pair attached. However, we are still not able to connect to the instance as a) SSH connections to our VM are not permitted and b) we actually don't the the private key to authorize ourself against the instance.

## Runtime updates and writing files

After we now learned that some changes actually require specific resources (in our case the instance) to be recreated, other changes can be applied during runtime.
For example, adding a security group. We need that security group to allow SSH access using TCP 22. While we allow access from virtually anywhere using `0.0.0.0/0` this should be done in production environment and our Lacework platform will actually warn you about this misconfiguration using our cloud compliance reporting.

Lets add the following code to your `main.tf` file:

```hcl
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
```

To create an `aws_security_group` we need to have the id of the current VPC. To do so we can use another resource called a data source.
It works similar to a resource, but uses `data`instead of `resources` as type.
Using a data source you can retreive information about existing resources that might not be managed by Terraform.
We use it to get the id of the default VPC. This id is then used to create the `aws_security_group`

We also need to assign this security group to our instance using the `vpc_security_group_ids = [aws_security_group.allow_ssh.id]` attribute.

```hcl
resource "aws_instance" "web" {
  ami                    = "ami-091f21ecba031b39a"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "HelloVM"
  }
}
```

While we only worked with strings as inputs so far, as you can see the `vpc_security_group_ids` attribute is actually using another input type: a list, indicated by the square brackets []l
Terraform supports many additional input types, like bool, number, map, set and so on: <https://www.terraform.io/docs/language/values/variables.html#type-constraints>

Before apply this configuration change we want to make sure that we have the SSH key available in our filesystem to connecto to our instance.
For this we can use another resource called `local_file`. This will take the private key generated by the `tls_private_key.ssh` resource and save it in our working directory.
We use a Terraform internal path variables for this called `path.root`, which is documented here: <https://www.terraform.io/docs/language/expressions/references.html#filesystem-and-workspace-info>

```hcl
resource "local_file" "ssh" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.root}/ssh.key"
  file_permission = "0400"
}
```
Time to apply our configuration and finally connect to our instance. Just make sure to run `terraform init` before you run `terraform apply`.
This is required to download the new provider used by `local_file`

```hcl
random_id.id: Refreshing state... [id=3uY-DQ]
tls_private_key.ssh: Refreshing state... [id=89556c7fb256835192af03afacf600f42c8360d1]
aws_key_pair.ssh: Refreshing state... [id=dee63e0d-ssh]
aws_instance.web: Refreshing state... [id=i-0c5413bca1e9443a0]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                                   = "i-0c5413bca1e9443a0"
        tags                                 = {
            "Name" = "HelloVM"
        }
      ~ vpc_security_group_ids               = [
          - "sg-43af6e2b",
        ] -> (known after apply)
        # (28 unchanged attributes hidden)





        # (5 unchanged blocks hidden)
    }

  # aws_security_group.allow_ssh will be created
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
      + name                   = "dee63e0d-allow-ssh"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = "vpc-70f8d919"
    }

  # local_file.ssh will be created
  + resource "local_file" "ssh" {
      + content              = (sensitive)
      + directory_permission = "0777"
      + file_permission      = "0400"
      + filename             = "./ssh.key"
      + id                   = (known after apply)
    }

Plan: 2 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.ssh: Creating...
local_file.ssh: Creation complete after 0s [id=3b73e3cbad7544912c96604f5fa7ec4c550f37a5]
aws_security_group.allow_ssh: Creating...
aws_security_group.allow_ssh: Creation complete after 2s [id=sg-02677b1b9728beb37]
aws_instance.web: Modifying... [id=i-0c5413bca1e9443a0]
aws_instance.web: Modifications complete after 1s [id=i-0c5413bca1e9443a0]

Apply complete! Resources: 2 added, 1 changed, 0 destroyed.

Outputs:

public_ip = "3.123.29.247"
```

As you can see from the output, this time we do an in-place update to attach the security group and you should also find a file called `ssh.key` in your file system.

Using ssh you can now finally connect to your instance.

```bash
ssh -i ssh.key ubuntu@3.123.29.247
```

or you can use the output of the public IP directly in our command line: 
```bash
ssh -i ssh.key ubuntu@$(terraform output -raw public_ip)
```

## User inputs using variables and removing static code

Now that our instance is up and running and we finally can connect we want to make our code a little bit more dynamic and configurable.
Looking at the code you see that we actually hardcode the AWS region used.
While `eu-central-1` is a perfectly fine location for me (only living 70km away from Frankfurt) other users might not be happy with that.

So, lets introduce input variables. By default every Terraform workspace should have a `variables.tf` file when input variables are used.
Copy and paste the code below to your `variables.tf` file.

```hcl
variable "aws_default_region" {
  description = "If you want to change the default region to another region, use this variable. Examples could be us-west-2 or ap-north-1."
  type        = string
  default     = "eu-central-1"
}
```

Each variable has its unique name that is used to reference it, our variable called `aws_default_region` is referenced as `var.aws_default_region` within Terraform.
You can add type, default values, descriptions and even do validation of variable inputs. For more information have a look at the documentation: <https://www.terraform.io/docs/language/values/variables.html>

We use a simple variable of type string using `eu-central-1` as default value.

And we want to use this variable within our provider block. So we change the region from the static value of `"eu-central-1"` to `var.aws_default_region`.

```hcl
provider "aws" {
  region = var.aws_default_region
}
```

Now, if we apply this change and DO NOT change the region everything would work out okay.
But unfortunatly the AMI ids are specific to the different AWS region. The AMI id we are using for Ubuntu 20.04 is specific to the region `eu-central-1`.
For this reason we need to introduce a new data source (and because it is fun) to look up the Ubuntu 20.04 of the region you specify.

```hcl
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
```

Just add this to your `main.tf` file and make sure you use the output as input for the AMI used by your AWS instance.
For this, change it from `ami-091f21ecba031b39a` to `data.aws_ami.ubuntu.id`

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "HelloVM"
  }
}
```

When you apply this change and didn't change the region from `eu-central-1` to something else you will see that actually no change will happen.
You did refactor your code to make ti more dynamic and user friendly without actually changing the environment. Good job!

The last question however is, if you do not want to use the default value but change it how can you pass variable input?

## Destroy

Before we learn how to pass variables and create a new environmet based on our code in `us-west-2` we want to cleanup our existing environment.
And this is really easy with Terraform, just run `terraform destroy`.

This will have a look at your code, the state file and the real-world environment and then create a destroy plan.
Basically a reversed plan to delete every resource created by Terraform.

```hcl
random_id.id: Refreshing state... [id=3uY-DQ]
tls_private_key.ssh: Refreshing state... [id=89556c7fb256835192af03afacf600f42c8360d1]
local_file.ssh: Refreshing state... [id=3b73e3cbad7544912c96604f5fa7ec4c550f37a5]
aws_key_pair.ssh: Refreshing state... [id=dee63e0d-ssh]
aws_security_group.allow_ssh: Refreshing state... [id=sg-02677b1b9728beb37]
aws_instance.web: Refreshing state... [id=i-0c5413bca1e9443a0]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.web will be destroyed
  - resource "aws_instance" "web" {
      - ami                                  = "ami-091f21ecba031b39a" -> null
      - arn                                  = "arn:aws:ec2:eu-central-1:382007176316:instance/i-0c5413bca1e9443a0" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "eu-central-1c" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 2 -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-0c5413bca1e9443a0" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t3.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - key_name                             = "dee63e0d-ssh" -> null
      - monitoring                           = false -> null
      - primary_network_interface_id         = "eni-067744eb559585b73" -> null
      - private_dns                          = "ip-172-31-34-240.eu-central-1.compute.internal" -> null
      - private_ip                           = "172.31.34.240" -> null
      - public_dns                           = "ec2-3-123-29-247.eu-central-1.compute.amazonaws.com" -> null
      - public_ip                            = "3.123.29.247" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [
          - "dee63e0d-allow-ssh",
        ] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-85c8e3cf" -> null
      - tags                                 = {
          - "Name" = "HelloVM"
        } -> null
      - tags_all                             = {
          - "Name" = "HelloVM"
        } -> null
      - tenancy                              = "default" -> null
      - vpc_security_group_ids               = [
          - "sg-02677b1b9728beb37",
        ] -> null

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - credit_specification {
          - cpu_credits = "unlimited" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/sda1" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-0a228cb3f8151df51" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
        }
    }

  # aws_key_pair.ssh will be destroyed
  - resource "aws_key_pair" "ssh" {
      - arn         = "arn:aws:ec2:eu-central-1:382007176316:key-pair/dee63e0d-ssh" -> null
      - fingerprint = "11:eb:de:74:2b:81:45:c8:36:10:0b:3e:bc:e8:a2:bb" -> null
      - id          = "dee63e0d-ssh" -> null
      - key_name    = "dee63e0d-ssh" -> null
      - key_pair_id = "key-06adb38230317b52c" -> null
      - public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqYMyMEouYMo98RgWQeLYVYnfVK0BMuWVk9nvuJerQl+Evm0uF0DArBGLxUyV8D+qMKBNChKDTRins6I6wFHZaC0ask31RLO5egX9VaZqRerjxSfr1CF3O7k9xzXUfoJm8y0h3/tbHUUxMGqgE71lFK8/XXUNcRs0/Ye/8j/fzO6kQmi5EUy+YeZ5XixS2esz1TSfAFSgRZLsPTLXqZPi0YDUxJqYnfuOrajb3yFX0V2XydA0NvhyFral1e10VLqP99iywHXGL9igDD3dyFqp8Uj30ayKBAC1eM3U4f3S/9691k0iPf+zwt28HYcIOjEdOh7fNLvP3+3Pr5qvbT3u4bXz5er7O+29ZifABp58dBMrI3cF5gn6Xp26NZzusSoifd7yw4mn20mUhXzOH/Xj0JpuqLH/cAPAbdZrgTcZW1/KTodQfJoX00esxozG3xsDL0PFRjVEglL/KJQuifAHpxd9tmQLg4NBRo5CnfJgt+V6gUaPQNr93AznQ8U2zeSerb6u2kW3FZ99bOr4Xy6bPsVRX256qsbNP1V90f2sF3tfXnWSjH0d1W0gSAHTUZCfV9Wk+eAFZ97R8/qRzvODEVA+CaF5nf3kZZZ4927svaEFqjAMWgI1CKrcsyn2awP2qE+Us5H9ns1vYNSMdO0bLRsCf6JNpjI0wdZZyuGnp9w==" -> null
      - tags        = {} -> null
      - tags_all    = {} -> null
    }

  # aws_security_group.allow_ssh will be destroyed
  - resource "aws_security_group" "allow_ssh" {
      - arn                    = "arn:aws:ec2:eu-central-1:382007176316:security-group/sg-02677b1b9728beb37" -> null
      - description            = "Managed by Terraform" -> null
      - egress                 = [] -> null
      - id                     = "sg-02677b1b9728beb37" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "SSH from 0.0.0.0/0"
              - from_port        = 22
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "dee63e0d-allow-ssh" -> null
      - owner_id               = "382007176316" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {} -> null
      - tags_all               = {} -> null
      - vpc_id                 = "vpc-70f8d919" -> null
    }

  # local_file.ssh will be destroyed
  - resource "local_file" "ssh" {
      - content              = (sensitive) -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0400" -> null
      - filename             = "./ssh.key" -> null
      - id                   = "3b73e3cbad7544912c96604f5fa7ec4c550f37a5" -> null
    }

  # random_id.id will be destroyed
  - resource "random_id" "id" {
      - b64_std     = "3uY+DQ==" -> null
      - b64_url     = "3uY-DQ" -> null
      - byte_length = 4 -> null
      - dec         = "3739631117" -> null
      - hex         = "dee63e0d" -> null
      - id          = "3uY-DQ" -> null
    }

  # tls_private_key.ssh will be destroyed
  - resource "tls_private_key" "ssh" {
      - algorithm                  = "RSA" -> null
      - ecdsa_curve                = "P224" -> null
      - id                         = "89556c7fb256835192af03afacf600f42c8360d1" -> null
      - private_key_pem            = (sensitive value)
      - public_key_fingerprint_md5 = "af:2c:bd:79:1a:55:95:98:52:dc:c7:50:4b:97:a8:08" -> null
      - public_key_openssh         = <<-EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqYMyMEouYMo98RgWQeLYVYnfVK0BMuWVk9nvuJerQl+Evm0uF0DArBGLxUyV8D+qMKBNChKDTRins6I6wFHZaC0ask31RLO5egX9VaZqRerjxSfr1CF3O7k9xzXUfoJm8y0h3/tbHUUxMGqgE71lFK8/XXUNcRs0/Ye/8j/fzO6kQmi5EUy+YeZ5XixS2esz1TSfAFSgRZLsPTLXqZPi0YDUxJqYnfuOrajb3yFX0V2XydA0NvhyFral1e10VLqP99iywHXGL9igDD3dyFqp8Uj30ayKBAC1eM3U4f3S/9691k0iPf+zwt28HYcIOjEdOh7fNLvP3+3Pr5qvbT3u4bXz5er7O+29ZifABp58dBMrI3cF5gn6Xp26NZzusSoifd7yw4mn20mUhXzOH/Xj0JpuqLH/cAPAbdZrgTcZW1/KTodQfJoX00esxozG3xsDL0PFRjVEglL/KJQuifAHpxd9tmQLg4NBRo5CnfJgt+V6gUaPQNr93AznQ8U2zeSerb6u2kW3FZ99bOr4Xy6bPsVRX256qsbNP1V90f2sF3tfXnWSjH0d1W0gSAHTUZCfV9Wk+eAFZ97R8/qRzvODEVA+CaF5nf3kZZZ4927svaEFqjAMWgI1CKrcsyn2awP2qE+Us5H9ns1vYNSMdO0bLRsCf6JNpjI0wdZZyuGnp9w==
        EOT -> null
      - public_key_pem             = <<-EOT
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqmDMjBKLmDKPfEYFkHi2
            FWJ31StATLllZPZ77iXq0JfhL5tLhdAwKwRi8VMlfA/qjCgTQoSg00Yp7OiOsBR2
            WgtGrJN9USzuXoF/VWmakXq48Un69Qhdzu5Pcc11H6CZvMtId/7Wx1FMTBqoBO9Z
            RSvP111DXEbNP2Hv/I/38zupEJouRFMvmHmeV4sUtnrM9U0nwBUoEWS7D0y16mT4
            tGA1MSamJ37jq2o298hV9Fdl8nQNDb4cha2pdXtdFS6j/fYssB1xi/YoAw93chaq
            fFI99GsigQAtXjN1OH90v/evdZNIj3/s8LdvB2HCDoxHToe3zS7z9/tz6+ar2097
            uG18+Xq+zvtvWYnwAaefHQTKyN3BeYJ+l6dujWc7rEqIn3e8sOJp9tJlIV8zh/14
            9Cabqix/3ADwG3Wa4E3GVtfyk6HUHyaF9NHrMaMxt8bAy9DxUY1RIJS/yiULonwB
            6cXfbZkC4ODQUaOQp3yYLfleoFGj0Da/dwM50PFNs3knq2+rtpFtxWffWzq+F8um
            z7FUV9ueqrGzT9VfdH9rBd7X151kox9HdVtIEgB01GQn1fVpPngBWfe0fP6kc7zg
            xFQPgmheZ395GWWePdu7L2hBaowDFoCNQiq3LMp9msD9qhPlLOR/Z7Nb2DUjHTtG
            y0bAn+iTaYyNMHWWcrhp6fcCAwEAAQ==
            -----END PUBLIC KEY-----
        EOT -> null
      - rsa_bits                   = 4096 -> null
    }

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - public_ip = "3.123.29.247" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

local_file.ssh: Destroying... [id=3b73e3cbad7544912c96604f5fa7ec4c550f37a5]
local_file.ssh: Destruction complete after 0s
aws_instance.web: Destroying... [id=i-0c5413bca1e9443a0]
aws_instance.web: Still destroying... [id=i-0c5413bca1e9443a0, 10s elapsed]
aws_instance.web: Still destroying... [id=i-0c5413bca1e9443a0, 20s elapsed]
aws_instance.web: Destruction complete after 30s
aws_key_pair.ssh: Destroying... [id=dee63e0d-ssh]
aws_security_group.allow_ssh: Destroying... [id=sg-02677b1b9728beb37]
aws_key_pair.ssh: Destruction complete after 0s
tls_private_key.ssh: Destroying... [id=89556c7fb256835192af03afacf600f42c8360d1]
tls_private_key.ssh: Destruction complete after 0s
aws_security_group.allow_ssh: Destruction complete after 0s
random_id.id: Destroying... [id=3uY-DQ]
random_id.id: Destruction complete after 0s

Destroy complete! Resources: 6 destroyed.
```

You now can actually have a look at your state file `terraform.tfstate` to see that it is empty now.

## Re-deploy using user inputs

To deploy a new environment in another region using the `aws_default_region` variable we need to pass the new value to Terraform.
There are actually a couple of ways to do so and I listed them below by the precedence (with later sources taking precedence over earlier ones):

* Environment variables
* The `terraform.tfvars` file, if present.
* The `terraform.tfvars.json` file, if present.
* Any `*.auto.tfvars` or `*.auto.tfvars.json` files, processed in lexical order of their filenames.
* Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)

More details on that can be found in the documentation: <https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables>

We will quick and easy pass the variable using the `-var` option. Just run the following command to deploy the instance in `us-east-2`.

```bash
terraform apply -var="aws_default_region=us-east-2"
```

Remark: This will only work if you have a default VPC created in your AWS account which might not be true for every region.

You may now choose to proceed and create the environment in your new region or just cancel the plan.
Remmember to destroy everything you create to not get an ugly suprise because you forgot to terminate the instance created.

## Whats next
Congragutlations, you now have enough knowledge to start your endevours with Terraform.
However, there is much more to learn but one thing in partictuar: modules.
For this reason we will cover modules in the next chapter.

Until then, there are some additonal topics you should know about advance your Terraform skills:
 
* Local Values: <https://www.terraform.io/docs/language/values/locals.html>
* Expressions: <https://www.terraform.io/docs/language/expressions/index.html>
  * Learn how to use conditionals: <https://www.terraform.io/docs/language/expressions/conditionals.html>
  * Access data of lists and maps using Splat Expressions: <https://www.terraform.io/docs/language/expressions/splat.html>
* Functions: <https://www.terraform.io/docs/language/functions/index.html>
  * Read file: <https://www.terraform.io/docs/language/functions/file.html>
  * Encode and decode base64: <https://www.terraform.io/docs/language/functions/base64encode.html> and <https://www.terraform.io/docs/language/functions/base64decode.html>
* DRY pattern with 
  * for-each <https://www.terraform.io/docs/language/meta-arguments/for_each.html>
  * count <https://www.terraform.io/docs/language/meta-arguments/count.html>
* Using provider aliases: <https://www.terraform.io/docs/language/providers/configuration.html#alias-multiple-provider-configurations>
* Terraform CLI, discovery additional CLI commands: <https://www.terraform.io/docs/cli/index.html>

And don't forget to check out the Terraform registry: <https://registry.terraform.io>