# Site URL
$SiteUrl = "https://contoso.sharepoint.com/sites/TestSite"

# Output file
$OutputFile = "C:\Temp\SharePointGroupsAndMembers.csv"

# Connect
Connect-PnPOnline -Url $SiteUrl -Interactive

$Results = @()

# Get all SharePoint groups
$Groups = Get-PnPGroup

foreach ($Group in $Groups)
{
    Write-Host "Processing Group:" $Group.Title -ForegroundColor Cyan

    try
    {
        $Members = Get-PnPGroupMember -Identity $Group.Title

        if ($Members.Count -eq 0)
        {
            $Results += [PSCustomObject]@{
                SiteUrl      = $SiteUrl
                GroupName    = $Group.Title
                GroupOwner   = $Group.OwnerTitle
                MemberName   = ""
                LoginName    = ""
                Email        = ""
                PrincipalType= ""
            }
        }
        else
        {
            foreach ($Member in $Members)
            {
                $Results += [PSCustomObject]@{
                    SiteUrl       = $SiteUrl
                    GroupName     = $Group.Title
                    GroupOwner    = $Group.OwnerTitle
                    MemberName    = $Member.Title
                    LoginName     = $Member.LoginName
                    Email         = $Member.Email
                    PrincipalType = $Member.PrincipalType
                }
            }
        }
    }
    catch
    {
        Write-Warning "Failed to process group: $($Group.Title)"
    }
}

# Export results
$Results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "Export completed: $OutputFile" -ForegroundColor Green
