terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Smallest possible Terraform graph that Checkov can parse and produce a
# clean report against. No cloud resources -> no provider credentials needed.
resource "null_resource" "noop" {
  triggers = {
    value = "checkov-fixture"
  }
}
