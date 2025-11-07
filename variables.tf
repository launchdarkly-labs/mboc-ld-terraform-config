variable "launchdarkly_access_token" {
  description = "LaunchDarkly API access token"
  type        = string
  sensitive   = true
}

variable "view_maintainer_id" {
  description = "LaunchDarkly member ID to set as maintainer for views"
  type        = string
}

variable "team_maintainer_id" {
  description = "LaunchDarkly member ID to set as maintainer for teams"
  type        = string
}

variable "projects" {
  description = "Map of projects in the organizational hierarchy, contained within the MB.OC Solution"
  type = map(object({
    name = string
  }))
  default = {
    project_a = {
      name = "Project A"
    }
    project_b = {
      name = "Project B"
    }
    project_c = {
      name = "Project C"
    }
    project_d = {
      name = "Project D"
    }
  }
}

variable "products" {
  description = "Map of products in the organizational hierarchy, each referencing a project"
  type = map(object({
    name        = string
    project_key = string
  }))
  default = {
    alpha = {
      name        = "Product Alpha"
      project_key = "project_a"
    }
    beta = {
      name        = "Product Beta"
      project_key = "project_a"
    }
    gamma = {
      name        = "Product Gamma"
      project_key = "project_b"
    }
    delta = {
      name        = "Product Delta"
      project_key = "project_c"
    }
    epsilon = {
      name        = "Product Epsilon"
      project_key = "project_d"
    }
  }
}