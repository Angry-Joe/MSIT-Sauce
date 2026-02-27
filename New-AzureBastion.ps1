<#
Important Note: The deployment of the Azure Bastion host can take around 5 to 10 minutes to complete,
so be patient while this command runs. With this step completed, you have established a secure
foundation for your network, your database, and your management access.

What's Next?
The core infrastructure is now in place. The next logical step would be to create the Azure App
Service that will host your web application and integrate it with the WebApp-Subnet in our VNet.

Would you like to proceed with the PowerShell script for that?
#>

# --- Configuration Variables ---
$resourceGroupName = "YourResourceGroupName"
$location = "EastUS" # Must be the same region as your VNet
$vnetName = "ITSM-VNet"

# --- Bastion Specific Variables ---
$bastionHostName = "itsm-bastion-host"
$publicIpName = "itsm-bastion-pip" # Name for the Bastion's Public IP address


# --- Script Execution ---

# 1. Get the existing virtual network resource
Write-Host "Fetching VNet details..."
$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName

# 2. Create the Public IP Address for Azure Bastion
# It MUST be a 'Standard' SKU and 'Static' allocation.
Write-Host "Creating a standard public IP address for Bastion..."
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName `
    -Name $publicIpName `
    -Location $location `
    -AllocationMethod 'Static' `
    -Sku 'Standard'

# 3. Create the Azure Bastion Host
# This command links the Bastion service to your VNet and the Public IP.
Write-Host "Deploying Azure Bastion host. This may take 5-10 minutes..."
New-AzBastion -ResourceGroupName $resourceGroupName `
    -Name $bastionHostName `
    -PublicIpAddress $publicIp `
    -VirtualNetwork $virtualNetwork

Write-Host "Azure Bastion host '$bastionHostName' deployed successfully."
