# --- Configuration Variables ---
$resourceGroupName = "DR-HelpDesk-RG"
$location = "EastUS"
$vnetName = "DR-HelpDesk-VNet"
$vnetAddressPrefix = "10.0.0.0/16"

# --- Subnet Definitions ---

$webAppSubnetName = "WebApp-Subnet"
$webAppSubnetPrefix = "10.0.1.0/24"

$databaseSubnetName = "Database-Subnet"
$databaseSubnetPrefix = "10.0.2.0/24"

$bastionSubnetName = "AzureBastionSubnet" # This name is mandatory for the Bastion service
$bastionSubnetPrefix = "10.0.3.0/26"

$appParms       = @{ Name="WebApp-Subnet";      AddressPrefix="10.0.1.0/24" }
$dbParms        = @{ Name="Database-Subnet";    AddressPrefix="10.0.2.0/24" }
$bastionParms   = @{ Name="AzureBastionSubnet"; AddressPrefix="10.0.3.0/26" }

# --- Script Execution ---

# 1. Create the Subnet Configuration Objects in memory
$webAppSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $webAppSubnetName `
    -AddressPrefix $webAppSubnetPrefix
$databaseSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $databaseSubnetName `
    -AddressPrefix $databaseSubnetPrefix
$bastionSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $bastionSubnetName `
    -AddressPrefix $bastionSubnetPrefix

$webAppSubnet = New-AzVirtualNetworkSubnetConfig @$appParms
$databaseSubnet = New-AzVirtualNetworkSubnetConfig @$dbParms
$bastionSubnet = New-AzVirtualNetworkSubnetConfig @$bastionParms

# 2. Create the Virtual Network in Azure with the defined subnets
New-AzVirtualNetwork -Name $vnetName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AddressPrefix $vnetAddressPrefix `
    -Subnet $webAppSubnet, $databaseSubnet, $bastionSubnet

Write-Host "Virtual Network '$vnetName' and its subnets have been created successfully."
