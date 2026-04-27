# 1. Login if you're not already connected
Connect-AzAccount

# 2. Replace these with your exact names (case-sensitive)
$rg         = "DR-HelpDesk-RG"
$vnetName   = "DR-HelpDesk-VNet"
$drstorage  = "drhelpdeskstorage90477" # Must be globally unique

# 3. Run this
Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName | ConvertTo-Json -Depth 12

Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName |
    Format-List Name, Location, AddressSpace*, ProvisioningState

# Detailed subnet table
(Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName).Subnets |
    Format-Table Name, AddressPrefix, PrivateEndpointNetworkPolicies, ServiceEndpoints -AutoSize

# List all your resource groups
Get-AzResourceGroup | Select-Object ResourceGroupName

# List all VNets in a specific RG
Get-AzVirtualNetwork -ResourceGroupName $rg | Select-Object Name, Location, AddressSpace

# 1. SQL Server + DB details
Get-AzSqlServer -ResourceGroupName $rg | ConvertTo-Json -Depth 5
Get-AzSqlDatabase -ResourceGroupName $rg | Select-Object ServerName, DatabaseName, Status

# 2. Private DNS zone (must exist and be linked to your VNet)
Get-AzPrivateDnsZone -ResourceGroupName $rg | ConvertTo-Json
Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $rg | Format-Table

# 3. Check if you already have Storage Account or Function App
Get-AzStorageAccount -ResourceGroupName $rg | Select-Object StorageAccountName, CreationTime
Get-AzFunctionApp -ResourceGroupName $rg | Select-Object Name, Status, Kind

# Create network Storage Account
New-AzStorageAccount `
    -ResourceGroupName $rg `
    -Name "drhelpdeskstorage$(Get-Random -Minimum 1000 -Maximum 9999)" `
    -Location "eastus" `
    -SkuName Standard_LRS `
    -Kind StorageV2

$funcName = "drhelpdeskfunc"
Update-AzFunctionAppSetting -ResourceGroupName $rg -Name $funcName -AppSetting @{"WEBSITE_VNET_ROUTE_ALL"="1"}

# Verify it was set
Get-AzFunctionAppSetting -ResourceGroupName $rg -Name $funcName | Select-Object -ExpandProperty WEBSITE_VNET_ROUTE_ALL

Get-AzSqlDatabase -ResourceGroupName "DR-HelpDesk-RG" -ServerName "dr-helpdesk-sql-2026" |
    Select-Object DatabaseName, Status, CreationDate
