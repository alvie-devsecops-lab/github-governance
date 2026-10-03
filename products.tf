# Every product repo is one module call. Adding a repo = a PR here.

module "recordings_api" {
  source      = "./modules/product-repo"
  name        = "recordings-api"
  description = "Recordings API: challenge, signature verification, presigned upload (lab)"
  team        = "backend"

  depends_on = [github_team.backend] # the module looks the team up by slug
}
