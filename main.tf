terraform {
  required_version = ">= 1.13"
  required_providers {
    launchdarkly = {
      source  = "launchdarkly/launchdarkly"
      version = "2.26.0-beta.1"
    }
  }
}

provider "launchdarkly" {
  access_token = var.launchdarkly_access_token
}

# Interactive Investor Project
resource "launchdarkly_project" "interactive_investor" {
  key  = "interactive-investor"
  name = "Interactive Investor"
  default_client_side_availability {
    using_environment_id = true
    using_mobile_key     = true
  }
  
  # Development Environment
  environments {
    key   = "devl"
    name  = "Development"
    color = "3BBD96"
  }
  
  # QA Environment
  environments {
    key   = "qa"
    name  = "QA"
    color = "87CEEB"
  }
  
  # QA2 Environment
  environments {
    key   = "qa2"
    name  = "QA2"
    color = "F6D383"
  }
  
  # Production Environment
  # Marked as critical, requires comments, and confirmation of changes
  # Uses ServiceNow for approvals (needs to be configured in ServiceNow)
  environments {
    key   = "prod"
    name  = "Production"
    color = "F55F4B"
    critical = true
    require_comments = true
    confirm_changes = true
    approval_settings {
      required = true
      # ServiceNow integration is not yet configured in LaunchDarkly - commenting out for now
      # service_kind = "servicenow"
      # service_config = {
      #   template = "sys_id"
      #   detail_column = "change request column name (justification)"
      # }
    }
  }
}

# Views - used for managing access to feature flags used by the different teams
resource "launchdarkly_view" "squad_a" {
  key         = "squad-a"
  name        = "Squad A"
  project_key = launchdarkly_project.interactive_investor.key
  description = "View for Squad A's feature flags"
  maintainer_id = var.view_maintainer_id
  generate_sdk_keys = true
  tags = ["squad-a"]
}

resource "launchdarkly_view" "squad_b" {
  key         = "squad-b"
  name        = "Squad B"
  project_key = launchdarkly_project.interactive_investor.key
  description = "View for Squad B's feature flags"
  maintainer_id = var.view_maintainer_id
  generate_sdk_keys = true
  tags = ["squad-b"]
}

resource "launchdarkly_view" "squad_c" {
  key         = "squad-c"
  name        = "Squad C"
  project_key = launchdarkly_project.interactive_investor.key
  description = "View for Squad C's feature flags"
  maintainer_id = var.view_maintainer_id
  generate_sdk_keys = true
  tags = ["squad-c"]
}

# Custom Roles
# LD Admins Role - full access to LaunchDarkly (mimics built-in admin role)
resource "launchdarkly_custom_role" "ii_ld_admins" {
  key         = "ii-ld-admins"
  name        = "II: LD Admins"
  description = "Full administrative access to all LaunchDarkly resources including account settings, integrations, members, and all project resources"
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
    resources = ["proj/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:aiconfig/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:context-kind/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:destination/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:experiment/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:flag/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:holdout/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:segment/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:layer/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric-group/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:product-analytics-dashboard/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:view/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:release-pipeline/*"]
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

# Lead Engineers Role - scoped to specific view(s), can manage flags in non-critical environments, can request changes in critical environments
resource "launchdarkly_custom_role" "ii_lead_engineers" {
  key         = "ii-lead-engineers"
  name        = "II: Lead Engineers"
  description = "Can manage all flag actions in non-critical environments and submit change requests for critical environments. Full access to experiments, metrics, segments, and release pipelines. Scoped to specific views via role attributes."
  base_permissions = "no_access"
  
  # View project
  policy_statements {
    effect    = "allow"
    actions   = ["viewProject"]
    resources = ["proj/*"]
  }

  # View and manage views
  policy_statements {
    effect    = "allow"
    actions   = ["viewView", "linkFlagToView", "unlinkFlagFromView", "updateView"]
    resources = ["proj/*:view/$${roleAttribute/viewKeys}"]
  }
  
  # All flag actions in scoped to views
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:flag/*;view:$${roleAttribute/viewKeys}"]
  }
  
  # Deny flag actions in critical environments - can't review/apply change approval requests
  policy_statements {
    effect      = "deny"
    not_actions = ["reviewApprovalRequest", "applyApprovalRequest", "bypassRequiredApproval"]
    resources   = ["proj/*:env/*;{critical:true}:flag/*;view:$${roleAttribute/viewKeys}"]
  }
  
  # All segment actions
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:segment/*"]
  }

  # Deny review/apply change approval requests for segments in critical environments
  policy_statements {
    effect      = "deny"
    not_actions = ["reviewApprovalRequest", "applyApprovalRequest"]
    resources   = ["proj/*:env/*;{critical:true}:segment/*"]
  }
  
  # All actions on metrics
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric/*"]
  }
  
  # All actions on metric groups
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric-group/*"]
  }
  
  # All actions on experiments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:experiment/*"]
  }

  # All actions on experiment holdouts
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:holdout/*"]
  }
  
  # All actions on experiment layers
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:layer/*"]
  }

  # All actions on release pipelines
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:release-pipeline/*"]
  }
  
}

# Engineers Role - scoped to specific view(s), can only modify flags in non-critical environments
resource "launchdarkly_custom_role" "ii_developers" {
  key         = "ii-developers"
  name        = "II: Developers"
  description = "Can modify flags and segments in non-critical environments only. View-only access to critical environments. Full access to experiments, metrics, holdouts, and layers. No access to release pipelines. Scoped to specific views via role attributes."
  base_permissions = "no_access"
  
  # View project
  policy_statements {
    effect    = "allow"
    actions   = ["viewProject"]
    resources = ["proj/*"]
  }

  # View and manage views
  policy_statements {
    effect    = "allow"
    actions   = ["viewView", "linkFlagToView", "unlinkFlagFromView"]
    resources = ["proj/*:view/$${roleAttribute/viewKeys}"]
  }
  
  # Flag actions in non-critical environments only, scoped to views
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*;{critical:false}:flag/*;view:$${roleAttribute/viewKeys}"]
  }
  
  # Only allow flag actions that don't impact flag evaluations in critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["createFlag", "addReleasePipeline", "removeReleasePipeline", "replaceReleasePipeline", "updateDescription", "updateDeprecated", "updateFlagCustomProperties", "updateFlagDefaultVariations", "updateFlagVariations", "updateGlobalArchived", "updateIncludeInSnippet", "updateName", "updateTags", "updateTemporary"]
    resources = ["proj/*:env/*;{critical:true}:flag/*;view:$${roleAttribute/viewKeys}"]
  }
  
  # All segment actions in non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*;{critical:false}:segment/*"]
  }
  
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric/*"]
  }
  
  # All actions on metric groups
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric-group/*"]
  }
  
  # All actions on experiments in non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*;{critical:false}:experiment/*"]
  }

  # All actions on experiment holdouts in non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*;{critical:false}:holdout/*"]
  }
}

# Business Role - read-only access to flags, can manage experimentation resources
resource "launchdarkly_custom_role" "ii_business_users" {
  key         = "ii-business-users"
  name        = "II: Business Users"
  description = "Read-only access to flags. Full access to manage experiments, holdouts, layers, metrics, and metric groups in all environments. Ideal for product managers and business analysts running experiments."
  base_permissions = "no_access"
  
  # View project
  policy_statements {
    effect    = "allow"
    actions   = ["viewProject"]
    resources = ["proj/*"]
  }

  # View views
  policy_statements {
    effect    = "allow"
    actions   = ["viewView"]
    resources = ["proj/*:view/$${roleAttribute/viewKeys}"]
  }
  
  # All actions on experiments (both critical and non-critical environments)
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:experiment/*"]
  }
  
  # All actions on experiment holdouts (both critical and non-critical environments)
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:env/*:holdout/*"]
  }
  
  # All actions on experiment layers
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:layer/*"]
  }
  
  # All actions on metrics
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric/*"]
  }
  
  # All actions on metric groups
  policy_statements {
    effect    = "allow"
    actions   = ["*"]
    resources = ["proj/*:metric-group/*"]
  }
}

# QA Testers Role - can modify flag targeting in non-critical environments
resource "launchdarkly_custom_role" "ii_qa_testers" {
  key         = "ii-qa-testers"
  name        = "II: QA Testers"
  description = "Can modify flag targeting (toggle flags, update rules, targets, and prerequisites) in non-critical environments for testing purposes. Scoped to specific views via role attributes."
  base_permissions = "no_access"
  
  # View project
  policy_statements {
    effect    = "allow"
    actions   = ["viewProject"]
    resources = ["proj/*"]
  }
  
  # View views
  policy_statements {
    effect    = "allow"
    actions   = ["viewView"]
    resources = ["proj/*:view/$${roleAttribute/viewKeys}"]
  }
  
  # Modify flag targeting in non-critical environments
  policy_statements {
    effect    = "allow"
    actions   = ["updateOn", "updateFallthrough", "updateTargets", "updateRules", "updateOffVariation", "updatePrerequisites"]
    resources = ["proj/*:env/*;{critical:false}:flag/*;view:$${roleAttribute/viewKeys}"]
  }
}
