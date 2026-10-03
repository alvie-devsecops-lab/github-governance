# github-governance

The GitHub organization's rules, as code (Terraform). Lab for DevSecOps practice.

| File | What it manages |
|---|---|
| `org.tf` | Org settings: base permission `none`, members can't create repos |
| `teams.tf` | Teams and membership (access goes to teams, never people) |
| `repos.tf` | Repositories (born protected) |
| `rulesets.tf` | Branch rules: PR required, no force push, signed commits |

**Not in code:** org-wide 2FA enforcement (UI-only setting) — verified via API.

Changes go through a pull request; `main` is protected by the ruleset defined here.
State is local for this lab; in production it lives in an encrypted, locked S3 backend.
