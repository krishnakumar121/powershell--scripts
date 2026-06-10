# SharePoint PnP PowerShell Connection Script

A flexible PowerShell script that connects to SharePoint Online using PnP (Patterns and Practices) with support for multiple authentication mechanisms. Configure your preferred authentication method in a simple JSON file and the script handles the rest.

## Features

✨ **Multiple Authentication Methods:**
- **Interactive** - Browser-based user authentication
- **Web Login** - Alternative browser-based login
- **Client Credentials** - App registration with Client ID and Secret
- **Certificate Authentication** - Certificate-based authentication with thumbprint

🔧 **Easy Configuration** - Centralized `config.json` for all connection settings

🛡️ **Secure** - Handles sensitive credentials safely with SecureString conversion

✅ **Validation** - Checks configuration before connection attempts

📊 **Helpful Output** - Color-coded status messages and connection confirmation

## Prerequisites

### Required
- **PowerShell 5.0** or higher
- **PnP.PowerShell Module** - Install with:
  ```powershell
  Install-Module -Name "PnP.PowerShell" -Scope CurrentUser
  ```

### For Certificate Authentication
- Certificate must be installed in `Cert:\CurrentUser\My` certificate store
- Certificate thumbprint available in Windows Certificate Manager

## Installation

1. Clone or download this repository:
   ```bash
   git clone https://github.com/krishnakumar121/powershell--scripts.git
   cd powershell--scripts
   ```

2. Review and customize `config.json` for your environment

3. Ensure the PnP.PowerShell module is installed:
   ```powershell
   Install-Module -Name "PnP.PowerShell" -Scope CurrentUser
   ```

## Configuration

### config.json Structure

```json
{
  "siteUrl": "https://yourtenant.sharepoint.com/sites/yoursite",
  "authMechanism": "Interactive",
  "interactive": {
    "enabled": true
  },
  "webLogin": {
    "enabled": true
  },
  "clientCredentials": {
    "enabled": true,
    "clientId": "your-client-id-here",
    "clientSecret": "your-client-secret-here",
    "tenantId": "your-tenant-id-here"
  },
  "certificateAuth": {
    "enabled": true,
    "clientId": "your-client-id-here",
    "thumbprint": "your-certificate-thumbprint-here",
    "tenantId": "your-tenant-id-here"
  }
}
```

### Configuration Details

| Field | Required | Description |
|-------|----------|-------------|
| `siteUrl` | ✓ | Your SharePoint site URL |
| `authMechanism` | ✓ | Choose: `Interactive`, `WebLogin`, `ClientCredentials`, or `Certificate` |
| `interactive.enabled` | ✗ | Enable/disable interactive authentication |
| `webLogin.enabled` | ✗ | Enable/disable web login |
| `clientCredentials` | ✗ | App registration credentials (Client ID, Secret, Tenant ID) |
| `certificateAuth` | ✗ | Certificate details (Client ID, Thumbprint, Tenant ID) |

## Usage

### Basic Usage

```powershell
.\Connect-SharePoint.ps1
```

This uses the default `config.json` in the same directory.

### Specify Custom Config File

```powershell
.\Connect-SharePoint.ps1 -ConfigPath "C:\path\to\custom-config.json"
```

### Example Output

```
SharePoint Connection Script
Site URL: https://yourtenant.sharepoint.com/sites/yoursite
Authentication Mechanism: Interactive

Connecting to SharePoint with Interactive login...
✓ Successfully connected to SharePoint (Interactive)

You are now connected to SharePoint.
You can now run PnP commands against this site.
Connected to: Your Site Title
```

## Authentication Methods

### 1. Interactive Authentication
**Best for:** Development, testing, single-user scenarios

- Browser automatically opens for user login
- No stored credentials required
- Supports MFA (Multi-Factor Authentication)

**Setup:**
```json
{
  "authMechanism": "Interactive",
  "interactive": { "enabled": true }
}
```

### 2. Web Login
**Best for:** Alternative to interactive, browser-based login

- Similar to Interactive with browser authentication
- Can be useful if Interactive doesn't work in your environment

**Setup:**
```json
{
  "authMechanism": "WebLogin",
  "webLogin": { "enabled": true }
}
```

### 3. Client Credentials (App Registration)
**Best for:** Automated scripts, unattended processes, service accounts

**Prerequisites:**
1. Create an Azure AD App Registration
2. Generate a client secret
3. Grant necessary SharePoint permissions to the app

**Setup:**
```json
{
  "authMechanism": "ClientCredentials",
  "clientCredentials": {
    "enabled": true,
    "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "clientSecret": "your-client-secret-value",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}
```

### 4. Certificate Authentication
**Best for:** Highly secure scenarios, automated processes, service principals

**Prerequisites:**
1. Create an Azure AD App Registration
2. Create or upload a certificate
3. Install the certificate in Windows Certificate Store
4. Obtain certificate thumbprint

**Setup:**
```json
{
  "authMechanism": "Certificate",
  "certificateAuth": {
    "enabled": true,
    "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "thumbprint": "1234567890ABCDEF1234567890ABCDEF12345678",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}
```

**Find Certificate Thumbprint:**
```powershell
# List all certificates in personal store
Get-ChildItem -Path "Cert:\CurrentUser\My"

# Get specific certificate thumbprint
(Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object { $_.Subject -like "*YourCert*" }).Thumbprint
```

## Common Tasks After Connection

Once connected, you can use PnP PowerShell commands:

```powershell
# Get web information
Get-PnPWeb

# List all lists
Get-PnPList

# Get list items
Get-PnPListItem -List "My List"

# Add item to list
Add-PnPListItem -List "My List" -Values @{"Title"="New Item"}

# Upload file
Add-PnPFile -Path "C:\local\file.pdf" -Folder "Shared Documents"

# Get site users
Get-PnPUser

# Disconnect when done
Disconnect-PnPOnline
```

For more PnP commands, see the [official PnP.PowerShell documentation](https://pnp.github.io/powershell/).

## Troubleshooting

### Error: "Config file not found"
**Solution:** Ensure `config.json` is in the same directory as the script, or provide the full path using `-ConfigPath` parameter.

### Error: "Unknown authentication mechanism"
**Solution:** Check that `authMechanism` in config.json matches one of: `Interactive`, `WebLogin`, `ClientCredentials`, or `Certificate`.

### Error: "Certificate with thumbprint not found"
**Solution:** 
- Verify the thumbprint is correct
- Check certificate is installed in `Cert:\CurrentUser\My`
- Use `Get-ChildItem -Path "Cert:\CurrentUser\My"` to list certificates

### Error: "Failed to connect using Client Credentials"
**Possible causes:**
- Invalid Client ID or Client Secret
- Incorrect Tenant ID
- App registration doesn't have SharePoint permissions
- **Solution:** Verify credentials in Azure AD and grant Site.FullControl permission

### Error: "Connection timeout"
**Possible causes:**
- Network connectivity issues
- Incorrect SharePoint site URL
- **Solution:** Test URL in browser, check network connectivity

### Error: "Access Denied"
**Possible causes:**
- User/app doesn't have permissions to the site
- Site collection is in a different tenant
- **Solution:** Verify permissions and site URL in Azure AD and SharePoint Admin Center

## Security Best Practices

🔐 **Important:**

1. **Never commit `config.json` to version control** if it contains real credentials
   - Add to `.gitignore`: `config.json`
   - Use environment variables or secure vaults instead

2. **For Production:**
   - Use **Certificate Authentication** over Client Credentials when possible
   - Store secrets in Azure Key Vault, not in files
   - Use service principals with minimal required permissions
   - Rotate credentials regularly

3. **Local Development:**
   - Use **Interactive Authentication** for testing
   - Keep credentials local and never share

4. **Example .gitignore:**
   ```
   config.json
   *.pfx
   *.cer
   ```

## File Structure

```
powershell--scripts/
├── Connect-SharePoint.ps1      # Main connection script
├── config.json                 # Configuration file (customize this)
├── config.example.json         # Example configuration (reference)
└── README.md                   # This file
```

## Advanced Usage

### Custom Config Path in Script

```powershell
# Store config in a secure location
$configPath = "C:\SecureFolder\sp-config.json"
.\Connect-SharePoint.ps1 -ConfigPath $configPath
```

### Automation Example

```powershell
# Connect to SharePoint
.\Connect-SharePoint.ps1

# Perform operations
$items = Get-PnPListItem -List "MyList"
foreach ($item in $items) {
    Write-Host "Item: $($item['Title'])"
}

# Disconnect
Disconnect-PnPOnline
```

### Error Handling in Scripts

```powershell
# Import and use in another script
. .\Connect-SharePoint.ps1 -ConfigPath ".\config.json"

if ($?) {
    Write-Host "Successfully connected. Running operations..."
    # Your PnP commands here
} else {
    Write-Error "Connection failed. Exiting."
    exit 1
}
```

## Support & Documentation

- **PnP.PowerShell Documentation:** https://pnp.github.io/powershell/
- **Azure AD App Registration Guide:** https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app
- **SharePoint Developer:** https://learn.microsoft.com/en-us/sharepoint/dev/

## License

This project is provided as-is for educational and organizational use.

## Contributing

Contributions are welcome! Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests

## Changelog

### v1.0 (Initial Release)
- ✓ Interactive authentication
- ✓ Web Login authentication
- ✓ Client Credentials authentication
- ✓ Certificate authentication
- ✓ Configuration file support
- ✓ Error handling and validation

---

**Last Updated:** June 10, 2026

For questions or issues, please open a GitHub issue in the repository.
