# Documenting the potential scripts

These scripts help optimize some of the actions outlined in the `CMF - Runbook - Windows - Discover_Assess_Migrate_Hyperv_VMs_v1.0` document.

## `prepare-hyperv-host.ps1`

> [!IMPORTANT]
>
> This script is intended to be run on a Hyper-V host as part of the preparation steps for Azure Migrate.

This script automates the download and verification of the official Microsoft Azure Migrate Hyper-V script, which is used to **assess** and **prepare** Hyper-V hosts for migration to Azure.

## `prepare-user-account.ps1`

> [!NOTE]
>
> This script currently ONLY creates a role assignment (Owner or Contributor) for a specified user.

This script creates a role assignment (**Owner** or **Contributor**) and assigns the **Application Developer** role (EntraID) to specified account.

## `create-migrate-project.ps1`

This script creates a resource group and an Azure Migrate project.
