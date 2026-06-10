# SharePoint PnP Connection Script
# This script connects to SharePoint based on authentication mechanism specified in config.json

param(
    [string]$ConfigPath = ".\config.json"
)

function Get-ConfigFile {
    param(
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        Write-Error "Config file not found at: $Path"
        exit 1
    }
    
    try {
        $config = Get-Content $Path | ConvertFrom-Json
        return $config
    }
    catch {
        Write-Error "Failed to parse config file: $_"
        exit 1
    }
}

function Connect-SharePointInteractive {
    param(
        [string]$SiteUrl
    )
    
    Write-Host "Connecting to SharePoint with Interactive login..." -ForegroundColor Cyan
    try {
        Connect-PnPOnline -Url $SiteUrl -Interactive -WarningAction SilentlyContinue
        Write-Host "✓ Successfully connected to SharePoint (Interactive)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to connect using Interactive authentication: $_"
        return $false
    }
}

function Connect-SharePointWebLogin {
    param(
        [string]$SiteUrl
    )
    
    Write-Host "Connecting to SharePoint with Web Login..." -ForegroundColor Cyan
    try {
        Connect-PnPOnline -Url $SiteUrl -UseWebLogin -WarningAction SilentlyContinue
        Write-Host "✓ Successfully connected to SharePoint (Web Login)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to connect using Web Login: $_"
        return $false
    }
}

function Connect-SharePointClientCredentials {
    param(
        [string]$SiteUrl,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$TenantId
    )
    
    Write-Host "Connecting to SharePoint with Client Credentials..." -ForegroundColor Cyan
    
    if (-not $ClientId -or -not $ClientSecret -or -not $TenantId) {
        Write-Error "Client Credentials configuration incomplete. Please provide ClientId, ClientSecret, and TenantId."
        return $false
    }
    
    try {
        $secureClientSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
        Connect-PnPOnline -Url $SiteUrl `
            -ClientId $ClientId `
            -ClientSecret $secureClientSecret `
            -TenantId $TenantId `
            -WarningAction SilentlyContinue
        Write-Host "✓ Successfully connected to SharePoint (Client Credentials)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to connect using Client Credentials: $_"
        return $false
    }
}

function Connect-SharePointCertificate {
    param(
        [string]$SiteUrl,
        [string]$ClientId,
        [string]$Thumbprint,
        [string]$TenantId
    )
    
    Write-Host "Connecting to SharePoint with Certificate Authentication..." -ForegroundColor Cyan
    
    if (-not $ClientId -or -not $Thumbprint -or -not $TenantId) {
        Write-Error "Certificate authentication configuration incomplete. Please provide ClientId, Thumbprint, and TenantId."
        return $false
    }
    
    try {
        $cert = Get-ChildItem -Path "Cert:\CurrentUser\My" -Recurse | Where-Object { $_.Thumbprint -eq $Thumbprint } | Select-Object -First 1
        if (-not $cert) {
            Write-Error "Certificate with thumbprint '$Thumbprint' not found in certificate store."
            return $false
        }
        
        Connect-PnPOnline -Url $SiteUrl `
            -ClientId $ClientId `
            -Tenant $TenantId `
            -Certificate $cert `
            -WarningAction SilentlyContinue
        Write-Host "✓ Successfully connected to SharePoint (Certificate Auth)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to connect using Certificate authentication: $_"
        return $false
    }
}

function Connect-ToSharePoint {
    param(
        [object]$Config
    )
    
    $siteUrl = $Config.siteUrl
    $authMechanism = $Config.authMechanism
    
    if (-not $siteUrl) {
        Write-Error "Site URL not specified in configuration."
        return $false
    }
    
    Write-Host "SharePoint Connection Script" -ForegroundColor Yellow
    Write-Host "Site URL: $siteUrl" -ForegroundColor Yellow
    Write-Host "Authentication Mechanism: $authMechanism" -ForegroundColor Yellow
    Write-Host ""
    
    switch ($authMechanism.ToLower()) {
        "interactive" {
            if ($Config.interactive.enabled) {
                return Connect-SharePointInteractive -SiteUrl $siteUrl
            }
            else {
                Write-Error "Interactive authentication is disabled in configuration."
                return $false
            }
        }
        "weblogin" {
            if ($Config.webLogin.enabled) {
                return Connect-SharePointWebLogin -SiteUrl $siteUrl
            }
            else {
                Write-Error "Web Login authentication is disabled in configuration."
                return $false
            }
        }
        "clientcredentials" {
            if ($Config.clientCredentials.enabled) {
                return Connect-SharePointClientCredentials `
                    -SiteUrl $siteUrl `
                    -ClientId $Config.clientCredentials.clientId `
                    -ClientSecret $Config.clientCredentials.clientSecret `
                    -TenantId $Config.clientCredentials.tenantId
            }
            else {
                Write-Error "Client Credentials authentication is disabled in configuration."
                return $false
            }
        }
        "certificate" {
            if ($Config.certificateAuth.enabled) {
                return Connect-SharePointCertificate `
                    -SiteUrl $siteUrl `
                    -ClientId $Config.certificateAuth.clientId `
                    -Thumbprint $Config.certificateAuth.thumbprint `
                    -TenantId $Config.certificateAuth.tenantId
            }
            else {
                Write-Error "Certificate authentication is disabled in configuration."
                return $false
            }
        }
        default {
            Write-Error "Unknown authentication mechanism: $authMechanism"
            Write-Host "Supported mechanisms: Interactive, WebLogin, ClientCredentials, Certificate" -ForegroundColor Yellow
            return $false
        }
    }
}

# Main execution
$config = Get-ConfigFile -Path $ConfigPath
$connected = Connect-ToSharePoint -Config $config

if ($connected) {
    Write-Host ""
    Write-Host "You are now connected to SharePoint." -ForegroundColor Green
    Write-Host "You can now run PnP commands against this site." -ForegroundColor Green
    
    # Example: Get current web title
    $web = Get-PnPWeb
    Write-Host "Connected to: $($web.Title)" -ForegroundColor Green
}
else {
    Write-Error "Failed to connect to SharePoint."
    exit 1
}
