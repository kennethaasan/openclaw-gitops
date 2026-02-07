terraform {
  required_version = ">= 1.0.0"

  cloud {
    # The organization and workspace will be configured in the TFC UI
    # or passed via environment variables in GitHub Actions.
    organization = "YOUR_TFC_ORG"
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
