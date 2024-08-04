# Specify the Terraform version
terraform {
  required_version = ">= 1.0.0"

  # Specify the provider and its version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  # Adjust this version as needed
    }
  }
}

# Configure the AWS provider
provider "aws" {
  profile = "family-gpc-account"
}

# Data source to fetch the current AWS caller identity
data "aws_caller_identity" "current" {}

# Data source to fetch the AWS account alias
data "aws_iam_account_alias" "current" {}

# Output the current AWS account ID
output "current_account_id" {
  description = "The ID of the current AWS account"
  value       = data.aws_caller_identity.current.account_id
}

# Output the AWS account alias (friendly name)
output "account_alias" {
  description = "The friendly name (alias) of the AWS account"
  value       = data.aws_iam_account_alias.current.account_alias
}
