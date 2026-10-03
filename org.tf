# Org settings, managed by Terraform since dose 1 (imported, then this import
# block was removed — after the first apply it has nothing left to do).

resource "github_organization_settings" "lab" {
  billing_email = var.billing_email

  # Least privilege: members see only the repos their team is given.
  default_repository_permission = "none"

  # Only admins (through Terraform) create repos, so every repo is born
  # with the ruleset, CODEOWNERS and workflows — no "loose" repos.
  members_can_create_repositories         = false
  members_can_create_public_repositories  = false
  members_can_create_private_repositories = false

  members_can_create_pages              = true
  members_can_fork_private_repositories = false
  web_commit_signoff_required           = false
  has_organization_projects             = true
  has_repository_projects               = true
}
