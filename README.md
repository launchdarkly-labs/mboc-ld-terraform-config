# LaunchDarkly Terraform Management - MB OC

Terraform configuration for managing LaunchDarkly resources with a hierarchical organization model (Solution → Projects → Products) and role-based access control.

## Overview

This configuration manages LaunchDarkly resources across two projects:
- **mboc**: Production project with view-scoped access control
- **mboc-sandbox**: Sandbox project with full access for all teams

## Architecture

### Organizational Hierarchy

The configuration uses a three-tier hierarchy:
- **Solution** (MB.OC) → **Projects** → **Products**
- There is exactly one Solution: MB.OC
- Each Product maps to a View in LaunchDarkly
- Teams exist at Solution, Project, and Product levels, inheriting access to their respective Views

### Resources Created

1. **Views**: One per Product
2. **Teams**: 
   - Solution Team (MB.OC): Access to all Product Views across all Projects
   - Project Teams: Access to all Product Views within their Project
   - Product Teams: Access to their own Product's View
   - All teams are assigned the `mb_oc_sandbox` role (full sandbox access)
3. **Custom Roles**:
   - **LD Admins**: Full administrative access to all LaunchDarkly resources
   - **Developers**: View-scoped flag management in non-critical environments
   - **Maintainers**: View-scoped flag management with restricted actions in critical environments
   - **Secrets Managers**: View SDK keys for critical environments (supplementary role)
   - **Sandbox**: Full access to all project-scoped resources in the sandbox project

### Authorization Model

This configuration uses a two-tier authorization model:

1. **Custom Roles** (assigned to members): Define permission levels based on job functions
   - Permissions are scoped using `$${roleAttribute/viewKeys}` in policy statements
   - Role attributes are provided via team membership

2. **Teams** (assign members): Provide view scope via role attributes
   - Each team defines `viewKeys` that limit access to specific Views
   - Members inherit these role attributes when added to teams
   - Effective permissions = Custom Role permissions ∩ Team's view scope

## Setup

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Configure `terraform.tfvars`:
   - Set `launchdarkly_access_token` (your LaunchDarkly API token)
   - Set `view_maintainer_id` and `team_maintainer_id` (LaunchDarkly member IDs)
   - Optionally override `projects` and `products` to match your organization
   - Note: The Solution (MB.OC) is fixed and does not need to be configured

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Syncing State for a New Operator

This project uses **local Terraform state** (no remote backend is configured). If someone has already applied this configuration and you don't have their `terraform.tfstate` file, running `terraform plan` will show all resources as needing to be created — even though they already exist in LaunchDarkly. Applying in that state will fail with naming/key conflicts.

To sync your local state with the existing resources, run `terraform import` for each resource. The commands below assume the **default** `projects` and `products` variable values. If they have been customized in `terraform.tfvars`, adjust accordingly.

```bash
terraform init

# Custom Roles
terraform import launchdarkly_custom_role.mb_oc_ld_admins mb-oc-ld-admins
terraform import launchdarkly_custom_role.mb_oc_developers mb-oc-developers
terraform import launchdarkly_custom_role.mb_oc_maintainers mb-oc-maintainers
terraform import launchdarkly_custom_role.mb_oc_secrets_managers mb-oc-secrets-managers
terraform import launchdarkly_custom_role.mb_oc_sandbox mb-oc-sandbox

# Solution Team
terraform import launchdarkly_team.solution mboc-mb-oc

# Project Teams
terraform import 'launchdarkly_team.projects["project_a"]' mboc-project_a
terraform import 'launchdarkly_team.projects["project_b"]' mboc-project_b
terraform import 'launchdarkly_team.projects["project_c"]' mboc-project_c
terraform import 'launchdarkly_team.projects["project_d"]' mboc-project_d

# Product Teams
terraform import 'launchdarkly_team.products["alpha"]' mboc-alpha
terraform import 'launchdarkly_team.products["beta"]' mboc-beta
terraform import 'launchdarkly_team.products["gamma"]' mboc-gamma
terraform import 'launchdarkly_team.products["delta"]' mboc-delta
terraform import 'launchdarkly_team.products["epsilon"]' mboc-epsilon

# Views (import format: project_key/view_key)
terraform import 'launchdarkly_view.products["alpha"]' mboc/mb-oc-alpha
terraform import 'launchdarkly_view.products["beta"]' mboc/mb-oc-beta
terraform import 'launchdarkly_view.products["gamma"]' mboc/mb-oc-gamma
terraform import 'launchdarkly_view.products["delta"]' mboc/mb-oc-delta
terraform import 'launchdarkly_view.products["epsilon"]' mboc/mb-oc-epsilon
```

After importing, run `terraform plan` to verify the state matches — it should show no changes (or only minor diffs due to attribute defaults).

> **Tip:** To avoid this problem entirely, consider adding a [remote backend](https://developer.hashicorp.com/terraform/language/backend) (e.g. Terraform Cloud, S3+DynamoDB) so state is shared automatically.

## Default Projects and Products (Placeholders)

The `projects` and `products` variables in `variables.tf` contain **placeholder** values for demonstration purposes. They do **not** correspond to real production resources.

> **Do not apply the defaults to a live account.** Override them in `terraform.tfvars` with your actual organizational structure before running `terraform apply`. See [Customization](#customization) below.

**Default Projects:**

| Key | Name |
|-----|------|
| `project_a` | Project A |
| `project_b` | Project B |
| `project_c` | Project C |
| `project_d` | Project D |

**Default Products:**

| Key | Name | Parent Project |
|-----|------|----------------|
| `alpha` | Product Alpha | `project_a` |
| `beta` | Product Beta | `project_a` |
| `gamma` | Product Gamma | `project_b` |
| `delta` | Product Delta | `project_c` |
| `epsilon` | Product Epsilon | `project_d` |

## Customization

To align this configuration with your actual organizational structure, override the `projects` and `products` variables in `terraform.tfvars`. The Solution (MB.OC) is fixed and does not need to be configured.

### Defining your Projects

Add a `projects` block to `terraform.tfvars`. Each key becomes the internal identifier used to link Products to Projects:

```hcl
projects = {
  payments = {
    name = "Payments Platform"
  }
  checkout = {
    name = "Checkout Experience"
  }
  logistics = {
    name = "Logistics & Fulfillment"
  }
}
```

### Defining your Products

Add a `products` block to `terraform.tfvars`. Each Product must reference a valid `project_key` from the `projects` map above:

```hcl
products = {
  payments_api = {
    name        = "Payments API"
    project_key = "payments"
  }
  fraud_detection = {
    name        = "Fraud Detection"
    project_key = "payments"
  }
  cart = {
    name        = "Shopping Cart"
    project_key = "checkout"
  }
  shipping = {
    name        = "Shipping Service"
    project_key = "logistics"
  }
}
```

### Excluding Projects from Terraform

If certain projects are managed via the LaunchDarkly UI and you want to avoid conflicts with Terraform, set `managed = false` on those projects. Terraform will skip the project's team, and automatically skip all products (teams + views) that belong to it.

```hcl
projects = {
  payments = {
    name = "Payments Platform"
  }
  checkout = {
    name    = "Checkout Experience"
    managed = false  # this project's resources are managed via the UI
  }
}

products = {
  payments_api = {
    name        = "Payments API"
    project_key = "payments"        # managed — Terraform creates team + view
  }
  cart = {
    name        = "Shopping Cart"
    project_key = "checkout"        # automatically excluded (parent project is unmanaged)
  }
}
```

When `managed` is omitted it defaults to `true`, so existing configurations are unaffected.

### What gets created from these variables

For the first example above (all projects managed), Terraform would create:

- **3 Project Teams**: `Payments Platform`, `Checkout Experience`, `Logistics & Fulfillment`
- **4 Product Teams**: `Payments API`, `Fraud Detection`, `Shopping Cart`, `Shipping Service`
- **4 Views**: one per Product, scoped to that Product's feature flags
- **1 Solution Team**: MB.OC (always created, with access to all managed Views)

Each Project Team gets access to all Views belonging to its Products (e.g. the `Payments Platform` team sees both `Payments API` and `Fraud Detection` Views). Each Product Team gets access to only its own View.

### Member management

Teams are created with empty `member_ids`. Add members through the LaunchDarkly UI or API. The configuration uses `ignore_changes` on `member_ids` to prevent Terraform from overwriting membership on subsequent applies.
