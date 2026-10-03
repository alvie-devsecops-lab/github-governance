# Access is granted to TEAMS, never to individual people.
# Someone joins or leaves the team → their access follows automatically.

resource "github_team" "devsecops" {
  name        = "devsecops"
  description = "Owns the rules: governance repo, rulesets, pipelines"
  privacy     = "closed" # visible to org members, membership controlled
}

resource "github_team_membership" "devsecops_alvaro" {
  team_id  = github_team.devsecops.id
  username = "Alvie40"
  role     = "maintainer"
}

resource "github_team" "backend" {
  name        = "backend"
  description = "Writes the recordings API and worker"
  privacy     = "closed"
}
