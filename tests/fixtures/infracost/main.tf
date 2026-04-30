terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key                  = "fixture"
  secret_key                  = "fixture"
}

# Single small instance so Infracost has a known, cheap cost line item to
# report against. Never deployed - this fixture is read by `infracost breakdown`
# only. AWS keys above are placeholders and never authenticated.
resource "aws_instance" "fixture" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "infracost-fixture"
  }
}
