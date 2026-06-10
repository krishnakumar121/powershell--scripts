# -----------------------------
# CONFIG
# -----------------------------
$SiteUrl = "contoso.sharepoint.com:/sites/TestSite:"
$OutputFile = "C:\Temp\SP_AgentInventory.csv"

# -----------------------------
# CONNECT TO GRAPH
# -----------------------------
Connect-MgGraph -Scopes "Sites.Read.All", "Files.Read.All"

$GraphBase = "https://graph.microsoft.com/v1.0"

# -----------------------------
# GET SITE ID
# -----------------------------
$site = Invoke-MgGraphRequest -Method GET `
    -Uri "$GraphBase/sites/$SiteUrl"

$siteId = $site.id
Write-Host "Site ID: $siteId" -ForegroundColor Cyan

# -----------------------------
# GET DRIVES (DOCUMENT LIBRARIES)
# -----------------------------
$drives = Invoke-MgGraphRequest -Method GET `
    -Uri "$GraphBase/sites/$siteId/drives"

$results = @()

foreach ($drive in $drives.value)
{
    Write-Host "Scanning library: $($drive.name)" -ForegroundColor Yellow

    # -----------------------------
    # SEARCH FOR .agent FILES
    # -----------------------------
    try {
        $searchUri = "$GraphBase/drives/$($drive.id)/root/search(q='.agent')"
        $files = Invoke-MgGraphRequest -Method GET -Uri $searchUri

        foreach ($file in $files.value)
        {
            if ($file.name -like "*.agent")
            {
                $results += [PSCustomObject]@{
                    SiteId       = $siteId
                    Library      = $drive.name
                    FileName     = $file.name
                    FilePath     = $file.parentReference.path
                    FileId       = $file.id
                    WebUrl       = $file.webUrl
                    Created      = $file.createdDateTime
                    Modified     = $file.lastModifiedDateTime
                }
            }
        }
    }
    catch {
        Write-Warning "Could not scan library: $($drive.name)"
    }
}

# -----------------------------
# EXPORT
# -----------------------------
$results | Export-Csv $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "Done. Found $($results.Count) .agent files" -ForegroundColor Green
Write-Host "Output: $OutputFile"
