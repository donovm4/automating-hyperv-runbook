# Prepare an Azure user account

$isTestingEnvironment = $true

# Account needs Contributor or Owner on an Azure subscription
# Account needs permissions to register Microsoft Entra apps


### FUNCTIONS ###

function Import-Azure-Modules {

    Install-Module Microsoft.Entra -Scope CurrentUser
    
    Write-Host "Importing Azure PowerShell modules" -ForegroundColor Yellow
    
    # Ensure we are using Az modules 
    Import-Module Az.Accounts, Az.Resources, Microsoft.Entra -Force

    # Remove any AzureRM conflicts
    Get-Module -Name AzureRM* | Remove-Module -Force
    
    Write-Host "Azure PowerShell modules imported successfully" -ForegroundColor Green
}


function Check-Account-Status {

    $TenantForAzureLogin = "16b3c013-d300-468d-ac64-7eda0820b6d3"
    $SubscriptionForAzureLogin = "d717cc8e-8af6-4764-bb9a-c86a529be857"

    if ([string]::IsNullOrWhiteSpace($TenantForAzureLogin)) {
        $TenantForAzureLogin = Read-Host "Tenant ID for AUTHN: "
    }

    if ([string]::IsNullOrWhiteSpace($SubscriptionForAzureLogin)) {
        $SubscriptionForAzureLogin = Read-Host "Subscription ID for AUTHN: "
    }

    $ctx = Get-AzContext

    if ( ($ctx -eq $null) -or ($ctx.Account -eq $null) -or ([string]::IsNullOrWhiteSpace($ctx.Account.Id))) {
        Write-Host "There was no context found." -ForegroundColor Gray
        Write-Host "Running Connect-AzAccount..." -ForegroundColor Yellow
        Connect-AzAccount -Tenant $TenantForAzureLogin -Subscription $SubscriptionForAzureLogin
        #Set-AzContext -Tenant $TenantForAzureLogin -Subscription $SubscriptionForAzureLogin
        $ctx = Get-AzContext
    }

    if (-not (($ctx -eq $null) -or ($ctx.Account -eq $null) -or ([string]::IsNullOrWhiteSpace($ctx.Account.Id)))) {
        Write-Host $ctx -ForegroundColor Gray
    }

}


function Create-RoleAssignment {
    
    param(
        [string]$UserPrincipalName,
        [string]$RoleDefinitionName,
        [string]$SubscriptionID
    )

    if (-not [string]::IsNullOrWhiteSpace($SubscriptionID) -and -not [string]::IsNullOrWhiteSpace($UserPrincipalName) -and -not [string]::IsNullOrWhiteSpace($RoleDefinitionName)) {
        Write-Host "Attempting to grant $RoleDefinitionName on $UserPrincipalName" -ForegroundColor Yellow
        try {
            Write-Host "Attempting to grant $RoleDefinitionName to $UserPrincipalName on /subscriptions/$SubscriptionID" -ForegroundColor Yellow
            $User = Get-AzADUser -UserPrincipalName "donovanmccoy_microsoft.com#EXT#@fdpo.onmicrosoft.com"
            New-AzRoleAssignment -ObjectId $User.Id -RoleDefinitionName $RoleDefinitionName -Scope "/subscriptions/$SubscriptionID"
            Write-Host "Role Assignment successfully created!" -ForegroundColor Green
            Get-AzRoleAssignment -RoleDefinitionName $RoleDefinitionName -Scope "/subscriptions/$SubscriptionID" -ObjectId $User.Id
        }
        catch {
            Write-Error $_
        }
    }
}

function Clean-Tests {

    $ctx = Get-AzContext

    if ($isTestingEnvironment -and (-not (($ctx -eq $null) -or ($ctx.Account -eq $null) -or ([string]::IsNullOrWhiteSpace($ctx.Account.Id))))) {
        Write-Host "Test Environment: $isTestingEnvironment" -ForegroundColor Gray
        Write-Host "Disconnecting Azure Account for testing..." -ForegroundColor Yellow

        try {
            Disconnect-AzAccount | Out-Null
            Write-Host "Disconnected successfully" -ForegroundColor Green
        }
        catch {
            Write-Error $_
        }
    }

}

### VARIABLES ###

$UserPrincipalName = ""
$RoleDefinitionName = "Contributor"
$SubscriptionID = ""

### MAIN SCRIPT ###

Import-Azure-Modules

Clean-Tests

Check-Account-Status

Create-RoleAssignment -UserPrincipalName $UserPrincipalName -RoleDefinitionName $RoleDefinitionName -SubscriptionID $SubscriptionID

