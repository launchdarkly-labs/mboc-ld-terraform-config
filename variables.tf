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

variable "products" {
  description = "Map of products in the organizational hierarchy"
  type = map(object({
    name = string
  }))
  default = {
    alpha = {
      name = "Product Alpha"
    }
    beta = {
      name = "Product Beta"
    }
    gamma = {
      name = "Product Gamma"
    }
  }
}

variable "projects" {
  description = "Map of projects in the organizational hierarchy, each referencing a product"
  type = map(object({
    name        = string
    product_key = string
  }))
  default = {
    project_a = {
      name        = "Project A"
      product_key = "alpha"
    }
    project_b = {
      name        = "Project B"
      product_key = "alpha"
    }
    project_c = {
      name        = "Project C"
      product_key = "beta"
    }
    project_d = {
      name        = "Project D"
      product_key = "gamma"
    }
  }
}

variable "solutions" {
  description = "Map of solutions in the organizational hierarchy, each referencing a project"
  type = map(object({
    name        = string
    project_key = string
  }))
  default = {
    solution_1 = {
      name        = "Solution 1"
      project_key = "project_a"
    }
    solution_2 = {
      name        = "Solution 2"
      project_key = "project_a"
    }
    solution_3 = {
      name        = "Solution 3"
      project_key = "project_b"
    }
    solution_4 = {
      name        = "Solution 4"
      project_key = "project_c"
    }
    solution_5 = {
      name        = "Solution 5"
      project_key = "project_d"
    }
  }
}