# lacework-terraform-101 - lacework provider and modules

As you now have learned tha basics of Terraform and also how to work with modules it is time to introduce Lacework's Terraform provider as well as our modules.
Lacework provide a Terraform provider to interact with the Lacework cloud security platform, which is avaibale on the official Terraform registry: <https://registry.terraform.io/providers/lacework/lacework>

It allows you to configure cloud and container integrations, alert channels, resource groups and more.
Besides the provider we also offer different Terraform modules to make onboarding of customers nice and easy.

This chapter will cover how to use our modules for AWS and also automate the creation of agent tokens and directly use them while provisioning new EC2 instances.

Let's go.

## Prep your Lacework account and set up the CLI

In order to use the Lacework Terraform provider we need to make sure we have working Lacework API key.
While the Lacework provider allows you to hard-code API key and secret this is definitly against any best practice.
For this reason the Lacework provider, like most Terraform providers, also allows you to provide the API key and secret using environment variables or using the configuration file created by the Lacework CLI.

We will cover both approches as the Lacework CLI approach is probalby the better method when you work on your own machine while the environment variables approach is perfect for CI/CD pipelines.

### Lacework CLI

When working the Lacework security platform from your local machine the Lacework CLI is a perfect companion.
It not only allows you to query and configure the platform but also to save your Lacework accounts locally.

To install the Lacework CLI on your Mac you can easy do this using `brew`.

```bash
$ brew install lacework/tap/lacework-cli
```

Once you installed the CLI you can configure your account using the following command:

```bash
$ lacework configure                                                                                                                                                                                                18s  10:45:39
▸ Account: myaccount
▸ Access Key ID: ACCOUNT_ABCEF01234559B9B07114E834D8570F567C824039756E03
▸ Secret Access Key: *********************************
```

As seen in the example, just enter the account name access key and secret and your are good to go.
The Lacework provider will use the default account by default.

So list and see which account is default run the following command:

```bash
     PROFILE              ACCOUNT            SUBACCOUNT                             API KEY                                       API SECRET               V
-----------------+------------------------+---------------+----------------------------------------------------------+-----------------------------------+----
    whoami         whoami                                   ACCOUNT_ABCEF01234559B9B07114E834D8570F567C824039756E03   *****************************1234   2
  > myaccount      myaccount                                ACCOUNT_ABCEF01234559B9B07114E834D8570F567C824039756E03   *****************************1234   2
    europe         europe.fra                               ACCOUNT_ABCEF01234559B9B07114E834D8570F567C824039756E03   *****************************1234   2
```

The default account is marked with the `>` at the beginning.

More about the Lacework CLI, for example, how to install it on other systems can be found here: <https://github.com/lacework/go-sdk/wiki/CLI-Documentation>

### Environment variables

Another way of configuring credentials for a provider is the use of environment variables. This approach can be used on your local machine as well as in CI/CD pipelines.
For this to work just make sure you have the following environment viariables set before you run any Terraform plan, apply or destroy.

```bash
$ export LW_ACCOUNT="myaccount"
$ export LW_API_KEY="ACCOUNT_ABCEF01234559B9B07114E834D8570F567C824039756E03"
$ export LW_API_SECRET="_abc1234e243a645bcf173ef55b837c19"
$ terraform apply
```

For more details have a look here: <https://registry.terraform.io/providers/lacework/lacework/latest/docs#environment-variables>

## Start from scratch, configure the provider

In this section we have nothing prepped. You really have to start from scratch. To do so create a `main.tf` and add the Lacework provider block.
As will will use the AWS provider as well, make sure you add the AWS provider block as well and configure the region of your choice.

```hcl
provider "lacework" {}

provider "aws" {
  region = "eu-central-1"
}
```

As of Terraform 0.13 it is required to configure the required providers within the Terraform block.
This is required because the Terraform registry now support 3rd party providers in the Terraform registry.

You could add the terraform block to the `main.tf` itself but it is a best practice to do so in a file called `versions.tf`.

For this example we added the AWS and Lacework providers to the terraform block.

```hcl
terraform {
  required_providers {
    lacework = {
      source  = "lacework/lacework"
      version = "0.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
}
```

If you haven't already copy and paste the code block above to the newly created `versions.tf` fail.
Not doing so will result in an error as Terraform wouldn't know where to find the Lacework provider, as it is not published by HashiCorp directly (see following error)

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Finding latest version of hashicorp/lacework...
- Installing hashicorp/aws v3.61.0...
- Installed hashicorp/aws v3.61.0 (signed by HashiCorp)
╷
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider hashicorp/lacework: provider registry registry.terraform.io does not have a provider named registry.terraform.io/hashicorp/lacework
│
│ Did you intend to use lacework/lacework? If so, you must specify that source address in each module which requires that provider. To see which modules are currently depending on hashicorp/lacework, run the following command:
│     terraform providers
╵
```

Now that we have configred the terraform block we initaize our workspace running `terraform init` to download the providers required.

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "3.61.0"...
- Finding lacework/lacework versions matching "0.10.0"...
- Installing lacework/lacework v0.10.0...
- Installed lacework/lacework v0.10.0 (signed by a HashiCorp partner, key ID 51A8966FFFC33F87)
- Installing hashicorp/aws v3.61.0...
- Installed hashicorp/aws v3.61.0 (signed by HashiCorp)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

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

## Introduction to the Lacework Terraform provider

Using the Lacework Terraform provider you are able to configure the most important resources required during on-boarding to the Lacework cloud security platform.

Some examples would be:

* `lacework_agent_access_token`: to create agent access tokens
* `lacework_integration_aws_cfg`: to configure an AWS Config integration to analyze AWS configuration compliance.
* `lacework_integration_aws_ct`: to configure an AWS CloudTrail integration to analyze CloudTrail activity for monitoring cloud account security.
* `lacework_integration_gcp_cfg`: to configure GCP Config integration to analyze configuration compliance.
* `lacework_integration_ghcr`: to integrate a Github Container Registry (GHCR) with Lacework to assess, identify, and report vulnerabilities found in the operating system software packages in container images. 
* `lacework_resource_group_aws`:  to create an AWS Resource Group in order to categorize Lacework-identifiable assets.
* `lacework_alert_channel_slack`: to Configure Lacework to forward alerts to a Slack channel through an incoming webhook.
* `lacework_alert_channel_email`: to generate and send alert summaries and reports to email addresses using an email alert channel.

A full list of supported resources and data sources can be found in the offical provider documentation: <https://registry.terraform.io/providers/lacework/lacework/latest/docs>

To quickly check if our Lacework account is configured correctly (either by using the environment variables or Lacework CLI), we create Lacework email alert channel.
For this we add the following code to our `main.tf` file.

```hcl
resource "lacework_alert_channel_email" "my" {
  name       = "My alert channel configured by Terraform"
  recipients = ["tim.arenz@lacework.net"]
}
```

Before you apply this change, make sure you replace the address `change@me.example` with your own mail address and then run `terraform apply`.

```bash
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # lacework_alert_channel_email.my will be created
  + resource "lacework_alert_channel_email" "my" {
      + created_or_updated_by   = (known after apply)
      + created_or_updated_time = (known after apply)
      + enabled                 = true
      + id                      = (known after apply)
      + intg_guid               = (known after apply)
      + name                    = "My alert channel configured by Terraform"
      + org_level               = (known after apply)
      + recipients              = [
          + "tim.arenz@lacework.net",
        ]
      + test_integration        = true
      + type_name               = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

lacework_alert_channel_email.my: Creating...
lacework_alert_channel_email.my: Creation complete after 2s [id=LWINTTIM_4A2CD2FA85A82D362CCFDFCF65C638ADF786CD38B205E4A]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

If you now have a look at your Lacework portal you should see the newly configured alert channel.
Also, you should have received a test mail from Lacework.

Nicely done. You have configured your first resource using the Lacework provider.

## Introduction to the Lacework modules

While you can configure integration to AWS, GCP and Azure using the Lacework provider directly a lot of additional configuration steps are typically required.
This includes setting up IAM roles/permissions in the cloud, configuring storage buckets and log forwarders.

While setting up this all up using your own Terraform code would be a very good exercise (and you are encouraged to do so to better undestand the Lacework modules), Lacework provides modules to set up the most common integrations:

| Module name                  | Description                                                                                                                                  | Link                                                                |
| -----------------------------| -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| terraform-aws-config         | Terraform module for configuring an integration with Lacework and AWS for cloud resource configruation assessment.                           | <https://registry.terraform.io/modules/lacework/config/aws>         |
| terraform-aws-cloudtrail     | Terraform module for configuring an integration with Lacework and AWS for CloudTrail analysis.                                               | <https://registry.terraform.io/modules/lacework/cloudtrail/aws>     |
| terraform-gcp-config         | Terraform module for integrating Google Cloud Platform Organizations and Projects with Lacework for cloud resource configuration assessment. | <https://registry.terraform.io/modules/lacework/config/gcp>         |
| terraform-gcp-audit-log      | Terraform module for configuring an integration with Google Cloud Platform Organizations and Projects for Audit Logs analysis.               | <https://registry.terraform.io/modules/lacework/audit-log/gcp>      |
| terraform-azure-config       | Terraform module for integrating Azure Subscriptions and Tenants with Lacework for cloud resource configuration assessment.                  | <https://registry.terraform.io/modules/lacework/config/azure>       |
| terraform-azure-activity-log | Terraform module for configuring an integration with Azure Subscriptions and Tenants for Activity Log analysis.                              | <https://registry.terraform.io/modules/lacework/activity-log/azure> |

There are additional modules to integrate with Google Container Registry (GCR), deploy the Lacework agent on K8s or using the AWS SSM agent but those will not be covered here.
In fact, we will only cover the AWS config and cloudtrail module as the general concept of all modules is identical.

An overview of all modules can be found here: <https://registry.terraform.io/search/modules?namespace=lacework>

## Integrate AWS with Lacework

Before we start with this sectio, have a look at the Lacework documentation: <https://docs.lacework.com/aws-cloudtrail-integration-with-terraform>.
As you can see, integration using Terraform and the different clouds is very well documented. 

This documentation helps to understand what our modules do and what kind of permissions, resources, etc. will be created by using the modules.

But now lets dig in: for the integration of AWS and Lacework we first need to configure two providers - AWS and Lacework.
We already set this up in the `main.tf` file.

```hcl
provider "lacework" {}

provider "aws" {
  region = "eu-central-1"
}
```

### Configure the required IAM role

At this point we deviate a bit from the current documentation. As of today Lacework (at least on the AWS and GCP modules) uses nested modules.
While this works fine it is not according to best practice: <https://www.terraform.io/language/modules/develop/composition#dependency-inversion>

But are modules are very well written, an for this reason, even by default its not used we can apply best practices and unboundle modules - instead of using nested modules.

To do so we first use the [IAM role module](https://registry.terraform.io/modules/lacework/iam-role/aws/latest).

```hcl
module "lacework_iam_role" {
  source = "lacework/iam-role/aws"
  version = "0.2.2"
  iam_role_name = "lacework-101"
}
```