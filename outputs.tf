output "mb_oc_project" {
  description = "Mercedes-Benz OC project details"
  value = {
    id   = data.launchdarkly_project.mb_oc.id
    key  = data.launchdarkly_project.mb_oc.key
    name = data.launchdarkly_project.mb_oc.name
  }
}

# Note: Environments output removed as we're not using them in this configuration

output "views" {
  description = "Mercedes-Benz OC squad views"
  value = {
    squad_a = {
      id   = launchdarkly_view.squad_a.id
      key  = launchdarkly_view.squad_a.key
      name = launchdarkly_view.squad_a.name
    }
    squad_b = {
      id   = launchdarkly_view.squad_b.id
      key  = launchdarkly_view.squad_b.key
      name = launchdarkly_view.squad_b.name
    }
    squad_c = {
      id   = launchdarkly_view.squad_c.id
      key  = launchdarkly_view.squad_c.key
      name = launchdarkly_view.squad_c.name
    }
  }
}

output "teams" {
  description = "Mercedes-Benz OC squad teams"
  value = {
    squad_a = {
      id   = launchdarkly_team.squad_a.id
      key  = launchdarkly_team.squad_a.key
      name = launchdarkly_team.squad_a.name
    }
    squad_b = {
      id   = launchdarkly_team.squad_b.id
      key  = launchdarkly_team.squad_b.key
      name = launchdarkly_team.squad_b.name
    }
    squad_c = {
      id   = launchdarkly_team.squad_c.id
      key  = launchdarkly_team.squad_c.key
      name = launchdarkly_team.squad_c.name
    }
  }
}

output "custom_roles" {
  description = "Mercedes-Benz OC custom roles"
  value = {
    mb_oc_ld_admins = {
      id   = launchdarkly_custom_role.mb_oc_ld_admins.id
      key  = launchdarkly_custom_role.mb_oc_ld_admins.key
      name = launchdarkly_custom_role.mb_oc_ld_admins.name
    }
    mb_oc_lead_engineers = {
      id   = launchdarkly_custom_role.mb_oc_lead_engineers.id
      key  = launchdarkly_custom_role.mb_oc_lead_engineers.key
      name = launchdarkly_custom_role.mb_oc_lead_engineers.name
    }
    mb_oc_developers = {
      id   = launchdarkly_custom_role.mb_oc_developers.id
      key  = launchdarkly_custom_role.mb_oc_developers.key
      name = launchdarkly_custom_role.mb_oc_developers.name
    }
    mb_oc_business_users = {
      id   = launchdarkly_custom_role.mb_oc_business_users.id
      key  = launchdarkly_custom_role.mb_oc_business_users.key
      name = launchdarkly_custom_role.mb_oc_business_users.name
    }
    mb_oc_qa_testers = {
      id   = launchdarkly_custom_role.mb_oc_qa_testers.id
      key  = launchdarkly_custom_role.mb_oc_qa_testers.key
      name = launchdarkly_custom_role.mb_oc_qa_testers.name
    }
  }
}
