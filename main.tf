terraform {
  required_version = ">= 1.13"
  required_providers {
    launchdarkly = {
      source  = "launchdarkly/launchdarkly"
      version = "2.26.0-beta.4"
    }
  }
}

provider "launchdarkly" {
  access_token = var.launchdarkly_access_token
  api_host     = "https://app.eu.launchdarkly.com"
}

# MB OC Project - Using existing default project
data "launchdarkly_project" "mb_oc" {
  key = "mboc"
}

# Sandbox Project
data "launchdarkly_project" "mb_oc_sandbox" {
  key = "mboc-sandbox"
}

# Helper locals to compute hierarchy mappings and view keys for teams
locals {
  # Solution is fixed: MB.OC (there is exactly one Solution)
  solution_key = "mb-oc"
  solution_name = "MB.OC"

  # Map project key -> list of product keys
  project_to_products = {
    for project_key in keys(var.projects) : project_key => [
      for product_key, product in var.products : product_key
      if product.project_key == project_key
    ]
  }

  # View key for each product (will be used in views and teams)
  product_view_keys = {
    for product_key in keys(var.products) : product_key => "mb-oc-${product_key}"
  }

  # View keys for each product team (just their own view)
  product_team_view_keys = {
    for product_key in keys(var.products) : product_key => [
      local.product_view_keys[product_key]
    ]
  }

  # View keys for each project team (all product views in that project)
  project_team_view_keys = {
    for project_key in keys(var.projects) : project_key => [
      for product_key in local.project_to_products[project_key] : local.product_view_keys[product_key]
    ]
  }

  # View keys for the solution team (all product views across all projects)
  solution_team_view_keys = [
    for product_key in keys(var.products) : local.product_view_keys[product_key]
  ]
}

# Views - mapped to Products for managing access to feature flags
resource "launchdarkly_view" "products" {
  for_each = var.products

  key               = local.product_view_keys[each.key]
  name              = "MB OC: ${each.value.name}"
  project_key       = data.launchdarkly_project.mb_oc.key
  description       = "View for ${each.value.name}'s feature flags"
  maintainer_id     = var.view_maintainer_id
  generate_sdk_keys = true
  tags              = [each.key, "mb-oc", "product"]
}

# Teams - Solution Team (MB.OC)
resource "launchdarkly_team" "solution" {
  key         = "mboc-${local.solution_key}"
  name        = "MB OC: ${local.solution_name}"
  description = "Team for ${local.solution_name} members with access to all product views across all projects"
  maintainers = [var.team_maintainer_id]
  member_ids  = []
  custom_role_keys = [launchdarkly_custom_role.mb_oc_sandbox.key]

  role_attributes {
    key    = "viewKeys"
    values = local.solution_team_view_keys
  }

  lifecycle {
    ignore_changes = [member_ids]
  }
}

# Teams - Project Teams
resource "launchdarkly_team" "projects" {
  for_each = var.projects

  key         = "mboc-${each.key}"
  name        = "MB OC: ${each.value.name}"
  description = "Team for ${each.value.name} members with access to all product views in ${each.value.name}"
  maintainers = [var.team_maintainer_id]
  member_ids  = []
  custom_role_keys = [launchdarkly_custom_role.mb_oc_sandbox.key]

  role_attributes {
    key    = "viewKeys"
    values = local.project_team_view_keys[each.key]
  }

  lifecycle {
    ignore_changes = [member_ids]
  }
}

# Teams - Product Teams
resource "launchdarkly_team" "products" {
  for_each = var.products

  key         = "mboc-${each.key}"
  name        = "MB OC: ${each.value.name}"
  description = "Team for ${each.value.name} members with access to ${each.value.name} feature flags"
  maintainers = [var.team_maintainer_id]
  member_ids  = []
  custom_role_keys = [launchdarkly_custom_role.mb_oc_sandbox.key]

  role_attributes {
    key    = "viewKeys"
    values = local.product_team_view_keys[each.key]
  }

  lifecycle {
    ignore_changes = [member_ids]
  }
}
# Custom Roles
# LD Admins Role: full access to LaunchDarkly (mimics built-in admin role)
resource "launchdarkly_custom_role" "mb_oc_ld_admins" {
  key              = "mb-oc-ld-admins"
  name             = "MB OC: LD Admins"
  description      = "Full administrative access to all LaunchDarkly resources including account settings, integrations, members, and all project resources"
  base_permissions = "no_access"

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["acct"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["application/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["code-reference-repository/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["domain-verification/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["integration/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["member/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["member/*:token/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["pending-request/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:aiconfig/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:context-kind/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:destination/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:experiment/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:flag/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:holdout/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:segment/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:layer/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:metric/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:metric-group/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:product-analytics-dashboard/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:view/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:release-pipeline/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["relay-proxy-config/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["role/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["service-token/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["team/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["template/*"]
  }

  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["webhook/*"]
  }
}


# Developers Role: scoped to specific views, can create/update/archive/delete flags, make/review/apply changes in both critical and non-critical environments. Can manage release pipelines,segments, metrics, and metric groups. can view SDK keys for non-critical environments.
resource "launchdarkly_custom_role" "mb_oc_developers" {
  key              = "mb-oc-developers"
  name             = "MB OC: Developers"
  description      = "Can modify flags and segments in non-critical environments only. View-only access to critical environments. Full access to experiments, metrics, holdouts, and layers. No access to release pipelines. Scoped to specific views via role attributes."
  base_permissions = "no_access"

  # View project
  policy_statements {
    effect    = "allow"
    actions   = ["viewProject"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}"]
  }

  # Vies SDK keys for non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["viewSdkKey"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:false}"]
  }

  # View and manage views
  policy_statements {
    effect    = "allow"
    actions   = ["viewView", "linkFlagToView", "unlinkFlagFromView"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:view/$${roleAttribute/viewKeys}"]
  }

  # Allow access to product analytics dashboards
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:product-analytics-dashboard/*"]
  }

  # Flag actions, scoped to views
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:flag/*;view:$${roleAttribute/viewKeys}"]
  }

  # Deny bypassing required approval in critical environments
  policy_statements {
    effect    = "deny"
    actions   = ["bypassRequiredApproval"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:true}:flag/*;view:$${roleAttribute/viewKeys}"]
  }

  # All segment actions in all environments, scoped to views
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:segment/*"]
  }

  # All actions on metrics
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:metric/*"]
  }

  # All actions on metric groups
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:metric-group/*"]
  }

  # All actions on release pipelines
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:release-pipeline/*"]
  }

  # All actions on product analytics dashboards
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:product-analytics-dashboard/*"]
  }

  # Allow the creation of personal access tokens
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["member/*:token/*"]
  }
}

# Maintainers Role: scoped to specific views. Can update flag metadata, can request & apply changes in critical environments.
resource "launchdarkly_custom_role" "mb_oc_maintainers" {
  key              = "mb-oc-maintainers"
  name             = "MB OC: Maintainers"
  description      = "Read-only access to flags. Full access to manage experiments, holdouts, layers, metrics, and metric groups in all environments. Scoped to specific views via role attributes."
  base_permissions = "no_access"

  # View project
  policy_statements {
    effect    = "allow"
    actions   = ["viewProject"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}"]
  }

  # View views
  policy_statements {
    effect    = "allow"
    actions   = ["viewView", "linkFlagToView", "unlinkFlagFromView"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:view/$${roleAttribute/viewKeys}"]
  }

  # Allow all actions on flags, across all environments in the MBOC project, scoped to views
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:flag/*;view:$${roleAttribute/viewKeys}"]
  }

  # Deny creating, archiving, deleting, cloning flags. Deny reviewing change approval requests or bypassing required approval. Scoped to views. For project-scoped actions, denying an action in critical environments will prevent the action across all environments.
  policy_statements {
    effect    = "deny"
    actions   = ["createFlag", "updateGlobalArchived", "deleteFlag", "cloneFlag", "updateClientSideFlagAvailability", "reviewApprovalRequest", "bypassRequiredApproval"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:true}:flag/*;view:$${roleAttribute/viewKeys}"]
  }

  # All actions on product analytics dashboards
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:product-analytics-dashboard/*"]
  }
}

# Secrets Managers Role - view SDK keys for critical environments only (supplementary role to be used with Developer or Maintainer roles)
resource "launchdarkly_custom_role" "mb_oc_secrets_managers" {
  key              = "mb-oc-secrets-managers"
  name             = "MB OC: Secrets Managers"
  description      = "Can view secrets for critical environments only. This is a supplementary role meant to be used in combination with Developer or Maintainer roles."
  base_permissions = "no_access"

  # View SDK keys for critical environments only
  policy_statements {
    effect    = "allow"
    actions   = ["viewSdkKey"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:true}"]
  }
}

# Sandbox Role: full access to all project-scoped resources within the sandbox project
resource "launchdarkly_custom_role" "mb_oc_sandbox" {
  key              = "mb-oc-sandbox"
  name             = "MB OC: Sandbox"
  description      = "Full access to all project-scoped resources within the sandbox project"
  base_permissions = "no_access"

  # View and manage project
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}"]
  }

  # All actions on environments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*"]
  }

  # All actions on AI configs
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*:aiconfig/*"]
  }

  # All actions on context kinds
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:context-kind/*"]
  }

  # All actions on data export destinations
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*:destination/*"]
  }

  # All actions on experiments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*:experiment/*"]
  }

  # All actions on flags
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*:flag/*"]
  }

  # All actions on holdouts
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*:holdout/*"]
  }

  # All actions on segments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*:segment/*"]
  }

  # All actions on layers
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:layer/*"]
  }

  # All actions on metrics
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:metric/*"]
  }

  # All actions on metric groups
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:metric-group/*"]
  }

  # All actions on product analytics dashboards
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:env/*:product-analytics-dashboard/*"]
  }

  # All actions on release pipelines
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:release-pipeline/*"]
  }

  # All actions on views
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:view/*"]
  }

  # All actions on AI tools
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc_sandbox.key}:ai-tool/*"]
  }
}
