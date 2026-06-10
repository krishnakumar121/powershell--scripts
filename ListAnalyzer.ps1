param(
    [Parameter(Mandatory)]
    [string]$SiteUrl,

    [Parameter(Mandatory)]
    [string]$ListName
)

# Connect
Connect-PnPOnline -Url $SiteUrl -Interactive

Write-Host "Analyzing list '$ListName'..." -ForegroundColor Cyan

# Get list
$list = Get-PnPList -Identity $ListName

# Get fields
$fields = Get-PnPField -List $ListName

# Item count
$itemCount = $list.ItemCount

# Indexed columns
$indexedFields = $fields | Where-Object {
    $_.Indexed -eq $true
}

# Lookup columns
$lookupFields = $fields | Where-Object {
    $_.TypeAsString -eq "Lookup"
}

# Person/Group columns
$personFields = $fields | Where-Object {
    $_.TypeAsString -eq "User"
}

# Managed Metadata columns
$taxonomyFields = $fields | Where-Object {
    $_.TypeAsString -like "*Taxonomy*"
}

# Count items with unique permissions
$uniquePermissionCount = 0

Write-Host "Scanning for unique permissions..." -ForegroundColor Yellow

Get-PnPListItem -List $ListName -PageSize 2000 | ForEach-Object {

    if ($_.HasUniqueRoleAssignments)
    {
        $uniquePermissionCount++
    }
}

# Build report
$report = [PSCustomObject]@{
    ListName                = $list.Title
    ItemCount               = $itemCount
    IndexedColumnCount      = $indexedFields.Count
    LookupColumnCount       = $lookupFields.Count
    PersonColumnCount       = $personFields.Count
    ManagedMetadataCount    = $taxonomyFields.Count
    UniquePermissionItems   = $uniquePermissionCount
}

Write-Host ""
Write-Host "===== LIST SUMMARY =====" -ForegroundColor Green

$report | Format-List

Write-Host ""
Write-Host "===== INDEXED COLUMNS =====" -ForegroundColor Green

$indexedFields |
    Select-Object Title, InternalName |
    Format-Table -AutoSize

Write-Host ""
Write-Host "===== LOOKUP COLUMNS =====" -ForegroundColor Green

$lookupFields |
    Select-Object Title, InternalName |
    Format-Table -AutoSize

Write-Host ""
Write-Host "===== PERSON COLUMNS =====" -ForegroundColor Green

$personFields |
    Select-Object Title, InternalName |
    Format-Table -AutoSize

Write-Host ""
Write-Host "===== MANAGED METADATA COLUMNS =====" -ForegroundColor Green

$taxonomyFields |
    Select-Object Title, InternalName |
    Format-Table -AutoSize

# Optional CSV Export
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$report | Export-Csv `
    -Path ".\ListAnalysis_$($ListName)_$timestamp.csv" `
    -NoTypeInformation

Write-Host ""
Write-Host "Analysis complete." -ForegroundColor Green
