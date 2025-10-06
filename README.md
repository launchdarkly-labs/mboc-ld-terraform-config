# LaunchDarkly Terraform Management - Interactive Investor

Terraform configuration for managing LaunchDarkly resources for Interactive Investor.

## Project Structure

- **Project**: Interactive Investor (`interactive-investor`)
- **Environments**: Development (devl), QA, QA2, Production (prod)
- **Views**: Squad A, Squad B, Squad C
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

2. Edit `terraform.tfvars` with your LaunchDarkly API token

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

The configuration is pre-configured for Interactive Investor with Development, QA, QA2, and Production environments.