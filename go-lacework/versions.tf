terraform {
  required_providers {
    lacework = {
      source  = "lacework/lacework"
      version = "0.10.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
}
