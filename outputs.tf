output "interactive_investor_project" {
  description = "Interactive Investor project details"
  value = {
    id   = data.launchdarkly_project.interactive_investor.id
    key  = data.launchdarkly_project.interactive_investor.key
    name = data.launchdarkly_project.interactive_investor.name
  }
}

# Note: Environments output removed as we're not using them in this configuration

output "views" {
  description = "Views"
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

output "custom_roles" {
  description = "Custom roles"
  value = {
    ii_ld_admins = {
      id   = launchdarkly_custom_role.ii_ld_admins.id
      key  = launchdarkly_custom_role.ii_ld_admins.key
      name = launchdarkly_custom_role.ii_ld_admins.name
    }
    ii_lead_engineers = {
      id   = launchdarkly_custom_role.ii_lead_engineers.id
      key  = launchdarkly_custom_role.ii_lead_engineers.key
      name = launchdarkly_custom_role.ii_lead_engineers.name
    }
    ii_developers = {
      id   = launchdarkly_custom_role.ii_developers.id
      key  = launchdarkly_custom_role.ii_developers.key
      name = launchdarkly_custom_role.ii_developers.name
    }
    ii_business_users = {
      id   = launchdarkly_custom_role.ii_business_users.id
      key  = launchdarkly_custom_role.ii_business_users.key
      name = launchdarkly_custom_role.ii_business_users.name
    }
    ii_qa_testers = {
      id   = launchdarkly_custom_role.ii_qa_testers.id
      key  = launchdarkly_custom_role.ii_qa_testers.key
      name = launchdarkly_custom_role.ii_qa_testers.name
    }
  }
}
