variable "name" {
  description = "Repository name"
  type        = string
}

variable "description" {
  description = "One line describing the repo"
  type        = string
}

variable "team" {
  description = "Slug of the team that owns the code (gets write access, is the default code owner)"
  type        = string
}

variable "visibility" {
  description = "public in the Free-plan lab; private once on Team/Enterprise"
  type        = string
  default     = "public"
}
