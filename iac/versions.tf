terraform {
  required_version = ">= 1.0.0"

  cloud {
    organization = "aasan_dev"
    workspaces {
      name = "openclaw-prod"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
