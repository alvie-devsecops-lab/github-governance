# The mold every product repo is born from.
# One module call in github-governance = a repo that is protected from second one.

data "github_team" "owner" {
  slug = var.team
}

data "github_team" "devsecops" {
  slug = "devsecops"
}

locals {
  org = split("/", github_repository.this.full_name)[0]
}

resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  auto_init              = true # main must exist before files and rules
  has_wiki               = false
  delete_branch_on_merge = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true

  archive_on_destroy = true # removing the module call archives, never deletes
}

resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.this.name
  enabled    = true
}

# Access goes to teams: the owning team writes, devsecops administers.
resource "github_team_repository" "owner" {
  team_id    = data.github_team.owner.id
  repository = github_repository.this.name
  permission = "push"
}

resource "github_team_repository" "devsecops" {
  team_id    = data.github_team.devsecops.id
  repository = github_repository.this.name
  permission = "admin"
}

# Seed files, committed BEFORE the ruleset exists (see depends_on below).
# After that, main only accepts PRs — so later edits go through a PR in the repo,
# and Terraform stops tracking content (ignore_changes) instead of fighting the rule.
resource "github_repository_file" "codeowners" {
  repository     = github_repository.this.name
  branch         = "main"
  file           = ".github/CODEOWNERS"
  commit_message = "chore: seed CODEOWNERS from github-governance"
  content        = <<-EOT
    # Seeded by github-governance. The owning team reviews code;
    # changes to the pipeline itself need devsecops.
    *          @${local.org}/${var.team}
    /.github/  @${local.org}/devsecops
  EOT

  lifecycle {
    ignore_changes = [content]
  }
}

resource "github_repository_file" "pr_checks" {
  repository     = github_repository.this.name
  branch         = "main"
  file           = ".github/workflows/pr-checks.yml"
  commit_message = "ci: seed pr-checks workflow from github-governance"
  content        = file("${path.module}/pr-checks.yml")

  lifecycle {
    ignore_changes = [content]
  }
}

resource "github_repository_ruleset" "protect_main" {
  name        = "protect-main"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"
  # No bypass_actors: nobody skips, not even org owners.

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion                = true # TURNS ON "Restrict deletions"
    non_fast_forward        = true # TURNS ON "Block force pushes"
    required_signatures     = true # TURNS ON "Require signed commits"
    required_linear_history = true # TURNS ON "Require linear history"

    pull_request {
      required_approving_review_count   = 0 # LAB: single human; real team = 1+ and code owner review
      require_code_owner_review         = false
      dismiss_stale_reviews_on_push     = true
      required_review_thread_resolution = true
      allowed_merge_methods             = ["squash"]
    }

    required_status_checks {
      strict_required_status_checks_policy = true # branch must be up to date with main
      required_check {
        context        = "ticket-link"
        integration_id = 15368 # GitHub Actions only — another app can't fake a green check
      }
    }
  }

  # The seed files must land on main before main starts requiring PRs.
  depends_on = [
    github_repository_file.codeowners,
    github_repository_file.pr_checks,
  ]
}
