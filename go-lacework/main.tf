provider "lacework" {}

provider "aws" {
  region = "eu-central-1"
}

resource "lacework_alert_channel_email" "my" {
  name       = "My alert channel configured by Terraform"
  recipients = ["tim.arenz@lacework.net"]
}
