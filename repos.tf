# The governance repo: where the rules live, OUTSIDE the repos they judge.
# In a real company this one is created by hand (bootstrap) and then imported;
# in the lab we let Terraform create it.

resource "github_repository" "governance" {
  name        = "github-governance"
  description = "Org rules as code: settings, teams, rulesets (lab)"
  visibility  = "public" # Free plan: rulesets only work on public repos

  auto_init              = true # creates main with a README, so rules have a branch to protect
  has_wiki               = false
  has_issues             = true
  delete_branch_on_merge = true
  allow_merge_commit     = false # squash only → one commit per PR, easy to audit
  allow_rebase_merge     = false
  allow_squash_merge     = true

  archive_on_destroy = true # if someone removes this block, archive instead of delete

  lifecycle {
    prevent_destroy = true # terraform refuses to destroy the room with the keys
  }
}

# Only the devsecops team administers the governance repo.
resource "github_team_repository" "devsecops_governance" {
  team_id    = github_team.devsecops.id
  repository = github_repository.governance.name
  permission = "admin"
}

# Dependabot alerts (the provider moved this out of github_repository).
resource "github_repository_vulnerability_alerts" "governance" {
  repository = github_repository.governance.name
  enabled    = true
}
