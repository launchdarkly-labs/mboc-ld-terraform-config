output "mb_oc_project" {
  description = "Mercedes-Benz OC project details"
  value = {
    id   = data.launchdarkly_project.mb_oc.id
    key  = data.launchdarkly_project.mb_oc.key
    name = data.launchdarkly_project.mb_oc.name
  }
}

output "views" {
  description = "Views for the Mercedes-Benz OC (MB.OC) Project. Mapped to Products."
  value = {
    for product_key, view in launchdarkly_view.products : product_key => {
      id   = view.id
      key  = view.key
      name = view.name
    }
  }
}

output "teams" {
  description = "LD Teams for the Mercedes-Benz OC (MB.OC) Project. Organized by hierarchy (Solution, Projects, Products)"
  value = {
    solution = {
      id   = launchdarkly_team.solution.id
      key  = launchdarkly_team.solution.key
      name = launchdarkly_team.solution.name
    }
    projects = {
      for project_key, team in launchdarkly_team.projects : project_key => {
        id   = team.id
        key  = team.key
        name = team.name
      }
    }
    products = {
      for product_key, team in launchdarkly_team.products : product_key => {
        id   = team.id
        key  = team.key
        name = team.name
      }
    }
  }
}

output "custom_roles" {
  description = "LD Custom Roles for the Mercedes-Benz OC (MB.OC) Project"
  value = {
    mb_oc_ld_admins = {
      id   = launchdarkly_custom_role.mb_oc_ld_admins.id
      key  = launchdarkly_custom_role.mb_oc_ld_admins.key
      name = launchdarkly_custom_role.mb_oc_ld_admins.name
    }
    mb_oc_developers = {
      id   = launchdarkly_custom_role.mb_oc_developers.id
      key  = launchdarkly_custom_role.mb_oc_developers.key
      name = launchdarkly_custom_role.mb_oc_developers.name
    }
    mb_oc_maintainers = {
      id   = launchdarkly_custom_role.mb_oc_maintainers.id
      key  = launchdarkly_custom_role.mb_oc_maintainers.key
      name = launchdarkly_custom_role.mb_oc_maintainers.name
    }
    mb_oc_secrets_managers = {
      id   = launchdarkly_custom_role.mb_oc_secrets_managers.id
      key  = launchdarkly_custom_role.mb_oc_secrets_managers.key
      name = launchdarkly_custom_role.mb_oc_secrets_managers.name
    }
  }
}
