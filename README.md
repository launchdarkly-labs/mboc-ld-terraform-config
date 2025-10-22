# LaunchDarkly Terraform Management - MB OC

Terraform configuration for managing LaunchDarkly resources for MB OC using an existing project.

## Project Structure

- **Project**: Uses existing LaunchDarkly project (`default`)
- **Views**: MB OC: Squad A (`mb-oc-squad-a`), MB OC: Squad B (`mb-oc-squad-b`), MB OC: Squad C (`mb-oc-squad-c`)
- **Teams**: MB OC: Squad A, MB OC: Squad B, MB OC: Squad C
- **Custom Roles**: LD Admins, Lead Engineers, Engineers, Business, QA Testers

## Design Logic

This configuration implements a two-tier authorization model:

### Custom Roles (Persona-based)
- **Purpose**: Define different permission levels based on job functions
- **Role Attributes**: Reference Views using `$${roleAttribute/viewKeys}` in policy statements
- **Assignment**: Assigned directly to LD Members without specifying role attributes at assignment time
- **Examples**: LD Admins (full access), Lead Engineers (can manage non-critical + request changes in critical), Developers (non-critical only), Business Users (read-only + experiments), QA Testers (testing permissions)

### Teams (Squad-based)
- **Purpose**: Organize members by squad/team within the organization
- **Role Attributes**: Each team has `viewKeys` attribute scoped to their specific squad view
- **Assignment**: Members inherit role attributes from team membership
- **Examples**: Squad A team members automatically get `viewKeys = ["mb-oc-squad-a"]`

### Authorization Flow
1. Members are assigned custom roles directly (defining their permission level)
2. Members are added to teams (inheriting squad-specific View access)
3. When accessing LaunchDarkly, members' effective permissions are the intersection of their custom role permissions AND their team's view scope
4. This allows different personas (roles) within the same squad to have different permission levels while maintaining squad-based access boundaries
5. Additionally, if in the future you decide to implement mapping between LD Custom Roles/Teams and IdP Security Groups, this approach allows reducing the number of the security groups that would need to be created

## Files

- `main.tf` - Main configuration
- `variables.tf` - Variable definitions  
- `outputs.tf` - Output definitions
- `terraform.tfvars.example` - Example variables

## Setup

1. Copy the example file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your LaunchDarkly API token and team maintainer ID

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

This configuration uses an existing LaunchDarkly project (`default`) and creates:
- **Views**: Three squad-specific views for organizing feature flags
- **Teams**: Three teams with squad-specific role attributes
- **Custom Roles**: Five custom roles with different permission levels for various team members
