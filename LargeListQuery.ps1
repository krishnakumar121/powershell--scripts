# Requires:
# Install-Module PnP.PowerShell

param(
    [string]$SiteUrl = "https://contoso.sharepoint.com/sites/demo",
    [string]$ListName = "LargeList"
)

Connect-PnPOnline -Url $SiteUrl -Interactive

Write-Host "Connected to $SiteUrl" -ForegroundColor Green

# ----------------------------------------------------------
# Method 1 - Simple Get-PnPListItem with Paging
# Good for reading all items
# ----------------------------------------------------------

Write-Host "`nMethod 1: Get-PnPListItem with PageSize" -ForegroundColor Cyan

$sw = [System.Diagnostics.Stopwatch]::StartNew()

$items = Get-PnPListItem `
    -List $ListName `
    -PageSize 2000

$count = $items.Count

$sw.Stop()

Write-Host "Retrieved $count items in $($sw.Elapsed)"


# ----------------------------------------------------------
# Method 2 - Only retrieve specific fields
# Much faster than loading every field
# ----------------------------------------------------------

Write-Host "`nMethod 2: Specific Fields" -ForegroundColor Cyan

$sw.Restart()

$items = Get-PnPListItem `
    -List $ListName `
    -Fields "ID","Title","Modified" `
    -PageSize 2000

$count = $items.Count

$sw.Stop()

Write-Host "Retrieved $count items in $($sw.Elapsed)"


# ----------------------------------------------------------
# Method 3 - CAML Query
# Best for filtering large lists
# ----------------------------------------------------------

Write-Host "`nMethod 3: CAML Query" -ForegroundColor Cyan

$camlQuery = @"
<View>
    <Query>
        <Where>
            <Geq>
                <FieldRef Name='ID'/>
                <Value Type='Counter'>10000</Value>
            </Geq>
        </Where>
    </Query>
    <RowLimit>5000</RowLimit>
</View>
"@

$sw.Restart()

$items = Get-PnPListItem `
    -List $ListName `
    -Query $camlQuery

$count = $items.Count

$sw.Stop()

Write-Host "Retrieved $count items in $($sw.Elapsed)"


# ----------------------------------------------------------
# Method 4 - Indexed Column Filter
# Recommended for large lists
# ----------------------------------------------------------

Write-Host "`nMethod 4: Indexed Column Query" -ForegroundColor Cyan

$camlQuery = @"
<View>
    <Query>
        <Where>
            <Eq>
                <FieldRef Name='Status'/>
                <Value Type='Text'>Active</Value>
            </Eq>
        </Where>
    </Query>
</View>
"@

$sw.Restart()

$items = Get-PnPListItem `
    -List $ListName `
    -Query $camlQuery

$count = $items.Count

$sw.Stop()

Write-Host "Retrieved $count items in $($sw.Elapsed)"


# ----------------------------------------------------------
# Method 5 - Folder Scoped Query
# Useful when data is partitioned by folders
# ----------------------------------------------------------

Write-Host "`nMethod 5: Folder Query" -ForegroundColor Cyan

$sw.Restart()

$items = Get-PnPFolderItem `
    -FolderSiteRelativeUrl "Lists/$ListName/2025" `
    -ItemType File

$sw.Stop()

Write-Host "Retrieved $($items.Count) items in $($sw.Elapsed)"


# ----------------------------------------------------------
# Method 6 - CSOM Direct Query
# Often fastest for large-scale processing
# ----------------------------------------------------------

Write-Host "`nMethod 6: CSOM Query" -ForegroundColor Cyan

$conn = Get-PnPConnection
$ctx = Get-PnPContext

$list = $ctx.Web.Lists.GetByTitle($ListName)

$query = New-Object Microsoft.SharePoint.Client.CamlQuery
$query.ViewXml = "<View><RowLimit>5000</RowLimit></View>"

$sw.Restart()

$listItems = $list.GetItems($query)

$ctx.Load($listItems)
$ctx.ExecuteQuery()

$sw.Stop()

Write-Host "Retrieved $($listItems.Count) items in $($sw.Elapsed)"


# ----------------------------------------------------------
# Method 7 - Search API
# Good when you don't need all columns
# ----------------------------------------------------------

Write-Host "`nMethod 7: Search Query" -ForegroundColor Cyan

$sw.Restart()

$results = Submit-PnPSearchQuery `
    -Query "ListId:*"

$sw.Stop()

Write-Host "Retrieved $($results.ResultRows.Count) results in $($sw.Elapsed)"


# ----------------------------------------------------------
# Method 8 - Batch Processing
# Recommended for huge lists
# ----------------------------------------------------------

Write-Host "`nMethod 8: Process in Batches" -ForegroundColor Cyan

$batchSize = 5000
$totalProcessed = 0

$sw.Restart()

Get-PnPListItem `
    -List $ListName `
    -PageSize $batchSize | ForEach-Object {

        # Process item here

        $totalProcessed++

        if ($totalProcessed % 5000 -eq 0)
        {
            Write-Host "Processed $totalProcessed items..."
        }
}

$sw.Stop()

Write-Host "Processed $totalProcessed items in $($sw.Elapsed)"
