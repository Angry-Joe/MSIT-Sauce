<#
Verification
After running the script, a Private DNS Zone named privatelink.database.windows.net will be automatically created in your resource group. This is how your web app will be able to resolve your database's standard hostname (e.g., yourserver.database.windows.net) to its new private IP address within the VNet.

You have now taken a massive step in securing your application architecture! What would you like to build next? We could proceed with scripting the Azure Bastion host for secure management access.

#>
# --- Configuration Variables ---
# !! Fill these in with your existing resource names !!
$resourceGroupName = "YourResourceGroupName"
$location = "EastUS" # Must be the same region as your VNet
$vnetName = "ITSM-VNet"
$databaseSubnetName = "Database-Subnet"

$sqlServerName = "YourSqlServerName" # The name of your existing Azure SQL Server
$privateEndpointName = "sqlep-itsm-01" # A name for the new private endpoint resource
$privateLinkConnectionName = "sqlConnection-itsm-01" # A name for the connection within the endpoint


# --- Script Execution ---

# 1. Get the existing virtual network and the specific subnet for the database
Write-Host "Fetching VNet and Subnet details..."
$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $databaseSubnetName -VirtualNetwork $virtualNetwork

# 2. Get the existing Azure SQL Server resource
Write-Host "Fetching Azure SQL Server details..."
$sqlServer = Get-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlServerName

# 3. Disable Public Network Access on the SQL Server
Write-Host "Disabling public network access on '$sqlServerName'..."
Set-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -PublicNetworkAccess "Disabled"

Write-Host "Public access disabled successfully."

# 4. Create the Private Endpoint
# This is a multi-step process: define the connection, then create the endpoint resource.

# Define the connection to the SQL server
$privateLinkServiceConnection = New-AzPrivateLinkServiceConnection -Name $privateLinkConnectionName `
    -PrivateLinkServiceId $sqlServer.Id `
    -GroupId "sqlServer" # This specific GroupId tells Azure you're connecting to a SQL Server

# Create the private endpoint resource in your database subnet
Write-Host "Creating the private endpoint..."
New-AzPrivateEndpoint -Name $privateEndpointName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Subnet $subnet `
    -PrivateLinkServiceConnection $privateLinkServiceConnection

Write-Host "Private endpoint '$privateEndpointName' created successfully. Your database is now secured."
