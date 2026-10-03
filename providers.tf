terraform {
  required_version = ">= 1.6"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Token comes from the GITHUB_TOKEN environment variable, never from this file.
provider "github" {
  owner = "alvie-devsecops-lab"
}
