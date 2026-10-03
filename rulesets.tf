# Step 8: the governance repo protects ITSELF first.
# "Lock the room with the keys before you open any other door."

resource "github_repository_ruleset" "governance_protect_main" {
  name        = "protect-main"
  repository  = github_repository.governance.name
  target      = "branch"
  enforcement = "active"
  # No bypass_actors block → nobody skips these rules, not even org owners.

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"] # main
      exclude = []
    }
  }

  rules {
    deletion                = true # TURNS ON "Restrict deletions": nobody deletes main
    non_fast_forward        = true # TURNS ON "Block force pushes": nobody rewrites history
    required_signatures     = true # TURNS ON "Require signed commits"
    required_linear_history = true # TURNS ON "Require linear history"

    pull_request {
      # LAB LIMITATION: this org has a single human, and nobody may approve
      # their own PR. With 1 required approval you could never merge.
      # So here: PR is mandatory (no direct push), approvals = 0.
      # In a real team: 1+ approval, code owner review, last-push approval.
      required_approving_review_count   = 0
      require_code_owner_review         = false
      require_last_push_approval        = false
      dismiss_stale_reviews_on_push     = true
      required_review_thread_resolution = true
      allowed_merge_methods             = ["squash"]
    }

    # required_status_checks comes later, together with governance.yml:
    # requiring a check that no workflow produces would block every PR forever.
  }
}
