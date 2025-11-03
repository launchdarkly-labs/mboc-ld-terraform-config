# LaunchDarkly Terraform Management - MB OC

Terraform configuration for managing LaunchDarkly resources with a hierarchical organization model (Products → Projects → Solutions) and role-based access control.

## Overview

This configuration manages LaunchDarkly resources across two projects:
- **mboc**: Production project with view-scoped access control
- **mboc-sandbox**: Sandbox project with full access for all teams

## Architecture

### Organizational Hierarchy

The configuration uses a three-tier hierarchy:
- **Products** → **Projects** → **Solutions**
- Each Solution maps to a View in LaunchDarkly
- Teams exist at Solution, Project, and Product levels, inheriting access to their respective Views

### Resources Created

1. **Views**: One per Solution, scoped to the `mboc` project
2. **Teams**: 
   - Solution Teams: Access to their own Solution's View
   - Project Teams: Access to all Solution Views within their Project
   - Product Teams: Access to all Solution Views within their Product
   - All teams are assigned the `mb_oc_sandbox` role (full sandbox access)
3. **Custom Roles**:
   - **LD Admins**: Full administrative access to all LaunchDarkly resources
   - **Developers**: View-scoped flag management in non-critical environments
   - **Maintainers**: View-scoped flag management with restricted actions in critical environments
   - **DevOps**: View SDK keys for critical environments (supplementary role)
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
   - Optionally override `products`, `projects`, and `solutions` to match your organization

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Customization

Edit `terraform.tfvars` to define your organizational hierarchy. The default structure includes example Products, Projects, and Solutions that can be replaced with your actual structure.

Member management: Teams are created with empty `member_ids`. Add members through the LaunchDarkly UI or API. The configuration uses `ignore_changes` on `member_ids` to prevent Terraform from managing membership directly.
