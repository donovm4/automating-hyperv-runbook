<#
.SYNOPSIS
Downloads the Azure Migrate Hyper-V script, validates Microsoft Authenticode signature,
and computes SHA256. Optionally compares to an expected SHA256.

.PARAMETER Uri
Download URI (aka.ms short link supported).

.PARAMETER OutFile
Where to save the downloaded script.

.PARAMETER ExpectedSha256
Optional known-good SHA256 (from a trusted source) to compare against.

.PARAMETER RequireMicrosoftPublisher
If set, enforces the signer subject contains "Microsoft".
#>

[CmdletBinding()]
param(
    [string]$Uri = "https://aka.ms/migrate/script/hyperv",
    [string]$OutFile = (Join-Path $PWD "MicrosoftAzureMigrate-Hyper-V.ps1"),
    # Expected SHA256 should be 0ad60e7299925eff4d1ae9f1c7db485dc9316ef45b0964148a3c07c80761ade2 as of February 17, 2026. This is likely to change as Microsoft updates the script.
    # [string]$ExpectedSha256 = "0dd9d0e2774bb8b33eb7ef7d97d44a90a7928a4b1a30686c5b01ebd867f3bd68", # based on CMF Runbook as of May 17, 2024
    [string]$ExpectedSha256 = "0ad60e7299925eff4d1ae9f1c7db485dc9316ef45b0964148a3c07c80761ade2",
    [switch]$RequireMicrosoftPublisher = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Download-File {
    param(
        [string]$SourceUri, 
        [string]$Destination
    )

    # Prefer BITS for resiliency; fallback to Invoke-WebRequest
    try {
        if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
            Start-BitsTransfer -Source $SourceUri -Destination $Destination
        } else {
            Invoke-WebRequest -Uri $SourceUri -OutFile $Destination -MaximumRedirection 10
        }
    }
    catch {
        # Fallback path if BITS fails (common on some locked-down servers)
        Invoke-WebRequest -Uri $SourceUri -OutFile $Destination -MaximumRedirection 10
    }
}

function Verify-Authenticode {
    param([string]$Path, [switch]$EnforceMicrosoft)

    $sig = Get-AuthenticodeSignature -FilePath $Path

    if ($sig.Status -ne 'Valid') {
        throw "Signature check FAILED. Status: $($sig.Status). Message: $($sig.StatusMessage)"
    }

    if ($EnforceMicrosoft) {
        $subject = $sig.SignerCertificate.Subject
        if ($subject -notmatch 'Microsoft') {
            throw "Signature is valid, but signer subject does not look like Microsoft. Subject: $subject"
        }
    }

    [pscustomobject]@{
        Status         = $sig.Status
        StatusMessage  = $sig.StatusMessage
        SignerSubject  = $sig.SignerCertificate.Subject
        Thumbprint     = $sig.SignerCertificate.Thumbprint
        NotBefore      = $sig.SignerCertificate.NotBefore
        NotAfter       = $sig.SignerCertificate.NotAfter
        TimeStamper    = if ($sig.TimeStamperCertificate) { $sig.TimeStamperCertificate.Subject } else { $null }
    }
}

function Get-Sha256 {
    param([string]$Path)
    (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

Write-Host "Downloading: $Uri" -ForegroundColor Yellow
Download-File -SourceUri $Uri -Destination $OutFile
Write-Host "Saved to:  $OutFile" -ForegroundColor Green

Write-Host "`nVerifying Authenticode signature..." -ForegroundColor Yellow
$signatureInfo = Verify-Authenticode -Path $OutFile -EnforceMicrosoft:$RequireMicrosoftPublisher
$signatureInfo | Format-List

Write-Host "`nComputing SHA256..." -ForegroundColor Yellow
$sha = Get-Sha256 -Path $OutFile
Write-Host "SHA256: $sha" -ForegroundColor Gray

if ($ExpectedSha256) {
    $expected = $ExpectedSha256.Trim().ToLowerInvariant()
    if ($sha -ne $expected) {
        throw "SHA256 mismatch! Expected: $expected  Actual: $sha"
    }
    Write-Host "SHA256 matches expected value." -ForegroundColor Green
} else {
    Write-Host "No -ExpectedSha256 provided; computed SHA256 shown above for your records." -ForegroundColor Gray
}

Write-Host "`nAll checks passed." -ForegroundColor Green

$RunScriptOnChecksPassed = $false

if ($RunScriptOnChecksPassed) {
    Write-Host ""
    Write-Host "Executing downloaded script..." -ForegroundColor Yellow
    $TempScriptPath = Join-Path (Get-Location).Path "MicrosoftAzureMigrate-Hyper-V.ps1"
    . $TempScriptPath
}

