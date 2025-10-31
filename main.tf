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

# Helper locals to compute hierarchy mappings and view keys for teams
locals {
  # Map solution key -> project key
  solution_to_project = {
    for solution_key, solution in var.solutions : solution_key => solution.project_key
  }

  # Map project key -> product key
  project_to_product = {
    for project_key, project in var.projects : project_key => project.product_key
  }

  # Map project key -> list of solution keys
  project_to_solutions = {
    for project_key in keys(var.projects) : project_key => [
      for solution_key, solution in var.solutions : solution_key
      if solution.project_key == project_key
    ]
  }

  # Map product key -> list of solution keys (all solutions under all projects in the product)
  product_to_solutions = {
    for product_key in keys(var.products) : product_key => flatten([
      for project_key, solution_keys in local.project_to_solutions : solution_keys
      if local.project_to_product[project_key] == product_key
    ])
  }

  # View key for each solution (will be used in views and teams)
  solution_view_keys = {
    for solution_key in keys(var.solutions) : solution_key => "mb-oc-${solution_key}"
  }

  # View keys for each solution team (just their own view)
  solution_team_view_keys = {
    for solution_key in keys(var.solutions) : solution_key => [
      local.solution_view_keys[solution_key]
    ]
  }

  # View keys for each project team (all solution views in that project)
  project_team_view_keys = {
    for project_key in keys(var.projects) : project_key => [
      for solution_key in local.project_to_solutions[project_key] : local.solution_view_keys[solution_key]
    ]
  }

  # View keys for each product team (all solution views in all projects under that product)
  product_team_view_keys = {
    for product_key in keys(var.products) : product_key => [
      for solution_key in local.product_to_solutions[product_key] : local.solution_view_keys[solution_key]
    ]
  }
}

# Views - mapped to Solutions for managing access to feature flags
resource "launchdarkly_view" "solutions" {
  for_each = var.solutions

  key               = local.solution_view_keys[each.key]
  name              = "MB OC: ${each.value.name}"
  project_key       = data.launchdarkly_project.mb_oc.key
  description       = "View for ${each.value.name}'s feature flags"
  maintainer_id     = var.view_maintainer_id
  generate_sdk_keys = true
  tags              = [each.key, "mb-oc", "solution"]
}

# Teams - Solution Teams
resource "launchdarkly_team" "solutions" {
  for_each = var.solutions

  key         = "mb-oc-${each.key}"
  name        = "MB OC: ${each.value.name}"
  description = "Team for ${each.value.name} members with access to ${each.value.name} feature flags"
  maintainers = [var.team_maintainer_id]
  member_ids  = []

  role_attributes {
    key    = "viewKeys"
    values = local.solution_team_view_keys[each.key]
  }

  lifecycle {
    ignore_changes = [member_ids]
  }
}

# Teams - Project Teams
resource "launchdarkly_team" "projects" {
  for_each = var.projects

  key         = "mb-oc-${each.key}"
  name        = "MB OC: ${each.value.name}"
  description = "Team for ${each.value.name} members with access to all solution views in ${each.value.name}"
  maintainers = [var.team_maintainer_id]
  member_ids  = []

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

  key         = "mb-oc-${each.key}"
  name        = "MB OC: ${each.value.name}"
  description = "Team for ${each.value.name} members with access to all solution views in ${each.value.name}"
  maintainers = [var.team_maintainer_id]
  member_ids  = []

  role_attributes {
    key    = "viewKeys"
    values = local.product_team_view_keys[each.key]
  }

  lifecycle {
    ignore_changes = [member_ids]
  }
}
# Custom Roles
# LD Admins Role - full access to LaunchDarkly (mimics built-in admin role)
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


# Developers Role - scoped to specific view(s), can only modify flags in non-critical environments
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

  # View and manage views
  policy_statements {
    effect    = "allow"
    actions   = ["viewView", "linkFlagToView", "unlinkFlagFromView"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:view/$${roleAttribute/viewKeys}"]
  }

  # Flag actions in non-critical environments only, scoped to views
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:false}:flag/*;view:$${roleAttribute/viewKeys}"]
  }

  # Only allow flag actions that don't impact flag evaluations in critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["createFlag", "addReleasePipeline", "removeReleasePipeline", "replaceReleasePipeline", "updateDescription", "updateDeprecated", "updateFlagCustomProperties", "updateFlagDefaultVariations", "updateFlagVariations", "updateGlobalArchived", "updateIncludeInSnippet", "updateName", "updateTags", "updateTemporary"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:true}:flag/*;view:$${roleAttribute/viewKeys}"]
  }

  # All segment actions in non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:false}:segment/*"]
  }

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

  # All actions on experiments in non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:false}:experiment/*"]
  }

  # All actions on experiment holdouts in non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:false}:holdout/*"]
  }
}

# Maintainers Role - read-only access to flags, can manage experimentation resources
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
    actions   = ["viewView"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:view/$${roleAttribute/viewKeys}"]
  }

  # All actions on experiments (both critical and non-critical environments)
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:experiment/*"]
  }

  # All actions on experiment holdouts (both critical and non-critical environments)
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*:holdout/*"]
  }

  # All actions on experiment layers
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:layer/*"]
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
}

# DevOps Role - view SDK keys for critical environments only (supplementary role to be used with Developer or Maintainer roles)
resource "launchdarkly_custom_role" "mb_oc_devops" {
  key              = "mb-oc-devops"
  name             = "MB OC: DevOps"
  description      = "Can view SDK keys for critical environments only. This is a supplementary role meant to be used in combination with Developer or Maintainer roles."
  base_permissions = "no_access"

  # View SDK keys for critical environments only
  policy_statements {
    effect    = "allow"
    actions   = ["viewSdkKey"]
    resources = ["proj/${data.launchdarkly_project.mb_oc.key}:env/*;{critical:true}"]
  }
}
