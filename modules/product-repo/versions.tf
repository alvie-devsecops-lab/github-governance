# Without this block Terraform assumes "hashicorp/github" inside the module —
# a different, unconfigured provider with no owner, so resources land in the
# token user's PERSONAL account instead of the org. Always declare the source.
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
