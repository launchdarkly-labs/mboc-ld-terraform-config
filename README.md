# LaunchDarkly Terraform Management - Interactive Investor

Terraform configuration for managing LaunchDarkly resources for Interactive Investor using an existing project.

## Project Structure

- **Project**: Uses existing LaunchDarkly project (`default`)
- **Views**: II: Squad A (`ii-squad-a`), II: Squad B (`ii-squad-b`), II: Squad C (`ii-squad-c`)
- **Custom Roles**: LD Admins, Lead Engineers, Engineers, Business, QA Testers

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

2. Edit `terraform.tfvars` with your LaunchDarkly API token and member ID

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

This configuration uses an existing LaunchDarkly project (`default`) and creates:
- **Views**: Three squad-specific views for organizing feature flags
- **Custom Roles**: Five custom roles with different permission levels for various team members
