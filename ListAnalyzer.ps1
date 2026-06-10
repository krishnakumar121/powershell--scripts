param(
    [string]$SiteUrl,
    [string]$ListName
)

Connect-PnPOnline -Url $SiteUrl -Interactive

$list = Get-PnPList -Identity $ListName

Write-Host "List: $($list.Title)"
Write-Host "Items: $($list.ItemCount)"

$fields = Get-PnPField -List $ListName

$indexedFields = $fields | Where-Object {
    $_.Indexed -eq $true
}

Write-Host "`nIndexed Columns"
$indexedFields | Select Title, InternalName

$lookupFields = $fields | Where-Object {
    $_.TypeAsString -eq "Lookup"
}

Write-Host "`nLookup Columns"
$lookupFields | Select Title

if($list.ItemCount -gt 5000 -and $indexedFields.Count -eq 0)
{
    Write-Warning "Large list detected without indexes."
}
