<#
    TODO
    Add Entra External ID for customers
    Integrate employee Entra IDs to ITSM


#># This is the order the scripts should run to build the project soup-to-nuts
### GLOBALS ###
$resourceGroupName = "DR-HelpDesk-RG"
$location = "EastUS"
$vnetName = "DR-HelpDesk-VNet"
$databaseSubnetName = "Database-Subnet"
$sqlServerName = "dr-helpdesk-sql-2026" # The name of your existing Azure SQL Server
$privateEndpointName = "sqlep-itsm-01" # A name for the new private endpoint resource
$privateLinkConnectionName = "sqlConnection-itsm-01" # A name for the connection within the endpoint
$bastionHostName = "itsm-bastion-host"
$publicIpName = "itsm-bastion-pip" # Name for the Bastion's Public IP address



# Create virtual network and subnets
function New-VNet {
    # --- Configuration Variables ---
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

    # 1. Create the Subnet Configuration Objects in memory
    $webAppSubnet = New-AzVirtualNetworkSubnetConfig @appParms
    $databaseSubnet = New-AzVirtualNetworkSubnetConfig @dbParms
    $bastionSubnet = New-AzVirtualNetworkSubnetConfig @bastionParms

    # 2. Create the Virtual Network in Azure with the defined subnets
    New-AzVirtualNetwork -Name $vnetName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -AddressPrefix $vnetAddressPrefix `
        -Subnet $webAppSubnet, $databaseSubnet, $bastionSubnet

    Write-Host "Virtual Network '$vnetName' and its subnets have been created successfully."
}

# Secure Azure SQL Database - disables public access and creates a private endpoint.

function Set-AzDBNetSecurityOptions {
    # --- Configuration Variables ---
    #$resourceGroupName = "YourRGName"
    #$location = "EastUS" # Must be the same region as your VNet
    #$vnetName = "YourVnetName"
    #$databaseSubnetName = "Database-Subnet"
    #$sqlServerName = "YourSqlServerName" # The name of your existing Azure SQL Server
    #$privateEndpointName = "sqlep-itsm-01" # A name for the new private endpoint resource
    #$privateLinkConnectionName = "sqlConnection-itsm-01" # A name for the connection within the endpoint

    <#
    Verification
    After running the script, a Private DNS Zone named privatelink.database.windows.net will be automatically created in your resource group. This is how your web app will be able to resolve your database's standard hostname (e.g., yourserver.database.windows.net) to its new private IP address within the VNet.

    You have now taken a massive step in securing your application architecture! What would you like to build next? We could proceed with scripting the Azure Bastion host for secure management access.

    #>
    # --- Configuration Variables ---
    # !! Fill these in with your existing resource names !!
    #$resourceGroupName = "YourResourceGroupName"
    #$location = "EastUS" # Must be the same region as your VNet
    #$vnetName = "ITSM-VNet"
    #$databaseSubnetName = "Database-Subnet"

    #$sqlServerName = "YourSqlServerName" # The name of your existing Azure SQL Server
    #$privateEndpointName = "sqlep-itsm-01" # A name for the new private endpoint resource
    #$privateLinkConnectionName = "sqlConnection-itsm-01" # A name for the connection within the endpoint


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
}

# Deploy Azure Bastion for secure management access to network
# . .\New-AzureBastion.ps1
function New-AzureBastion {
    # --- Configuration Variables ---
    #$resourceGroupName = "DR-HelpDesk-RG"
    #$location = "EastUS" # Must be the same region as your VNet
    #$vnetName = "DR-HelpDesk-VNet"
    #$bastionHostName = "itsm-bastion-host"
    #$publicIpName = "itsm-bastion-pip" # Name for the Bastion's Public IP address

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
}
# Crate App Service Plan - this is what allows the app to talk to SQL DB
# . .\New-AzureAppService.ps1
function New-AzureApp {
    # --- Configuration Variables ---
    $resourceGroupName = "DR-HelpDesk-RG"
    $location = "EastUS" # Must be the same region as your VNet
    $appServicePlanName = "DRHelpDesk-AppServicePlan"
    $webAppName = "drhelpdesk-webapp" # Must be globally unique across Azure
    $vnetName = "DR-HelpDesk-VNet"
    $webAppSubnetName = "WebApp-Subnet"
    # --- Script Execution ---
    # 1. Create the App Service Plan
    Write-Host "Creating App Service Plan '$appServicePlanName'..."
    New-AzAppServicePlan -Name $appServicePlanName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Tier "Standard" `
        -WorkerSize 1
    Write-Host "App Service Plan '$appServicePlanName' created successfully."
    # 2. Create the Web App and integrate it with the VNet
    Write-Host "Creating Web App '$webAppName' and integrating with VNet..."
    New-AzWebApp -Name $webAppName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -AppServicePlan $appServicePlanName
    # Get the existing virtual network and subnet for integration
    $virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $webAppSubnetName -VirtualNetwork $virtualNetwork
    # Integrate the Web App with the VNet using Regional VNet Integration (requires Standard or higher tier)
    Set-AzWebAppVnetRouteAllEnabled -ResourceGroupName $resourceGroupName `
        -WebAppName $webAppName `
        -VnetRouteAllEnabled $true
    Set-AzWebAppVnetIntegration -ResourceGroupName $resourceGroupName `
        -WebAppName $webAppName `
        -SubnetId $subnet.Id
    Write-Host "Web App '$webAppName' created and integrated with VNet successfully."
}
# Create and configure the App Gateway (pub endpoint, traffic distro, web app firewall)
# . .\New-ProjectAppGateway.ps1
function New-ProjectAppGateway {
    # --- Configuration Variables ---
    $resourceGroupName = "YourResourceGroupName"
    $location = "EastUS"
    $vnetName = "ITSM-VNet"

    # !! Use the globally unique name of the web app you created in the previous step !!
    $webAppName = "your-unique-webapp-name"

    # --- New Subnet for the Application Gateway ---
    $appGatewaySubnetName = "AppGateway-Subnet"
    $appGatewaySubnetPrefix = "10.0.4.0/24"

    # --- Application Gateway Variables ---
    $appGatewayName = "itsm-appgateway"
    $publicIpName = "itsm-appgateway-pip"
    $wafPolicyName = "itsm-waf-policy"


    # --- Script Execution ---

    # 1. Add a dedicated subnet for the Application Gateway to the VNet
    Write-Host "Adding subnet '$appGatewaySubnetName' to VNet '$vnetName'..."
    $virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
    Add-AzVirtualNetworkSubnetConfig -Name $appGatewaySubnetName -AddressPrefix $appGatewaySubnetPrefix -VirtualNetwork $virtualNetwork
    $virtualNetwork | Set-AzVirtualNetwork # This command applies the change

    # Refresh VNet variable to get the new subnet object
    $virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
    $appGatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name $appGatewaySubnetName -VirtualNetwork $virtualNetwork

    # 2. Create a Public IP Address for the Gateway
    Write-Host "Creating public IP for Application Gateway..."
    $publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName `
        -Name $publicIpName `
        -Location $location `
        -AllocationMethod 'Static' `
        -Sku 'Standard'

    # 3. Create the Gateway's IP Configuration
    Write-Host "Configuring frontend IP..."
    $frontendIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name 'appGatewayFrontendIP' `
        -PublicIPAddress $publicIp

    # 4. Create the Backend Address Pool (pointing to your App Service)
    Write-Host "Configuring backend address pool..."
    $webAppFqdn = (Get-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName).DefaultHostName
    $backendPool = New-AzApplicationGatewayBackendAddressPool -Name 'itsm-backend-pool' `
        -BackendFqdns $webAppFqdn

    # 5. Create the HTTP Settings and Health Probe
    Write-Host "Configuring HTTP settings and health probe..."
    # The health probe checks the health of your web app
    $probe = New-AzApplicationGatewayProbeConfig -Name 'itsm-probe' `
        -Protocol 'Http' `
        -HostName $webAppFqdn `
        -Path '/' `
        -Interval 30 `
        -Timeout 30 `
        -UnhealthyThreshold 3

    # The HTTP settings define how the gateway talks to the backend
    $httpSettings = New-AzApplicationGatewayBackendHttpSettings -Name 'itsm-http-settings' `
        -Port 80 `
        -Protocol 'Http' `
        -CookieBasedAffinity 'Disabled' `
        -Probe $probe `
        -RequestTimeout 30

    # 6. Create the Frontend Listener and Routing Rule
    Write-Host "Configuring listener and routing rule..."
    # The listener waits for incoming traffic on Port 80
    $listener = New-AzApplicationGatewayHttpListener -Name 'itsm-http-listener' `
        -Protocol 'Http' `
        -FrontendIPConfiguration $frontendIpConfig `
        -FrontendPort 80

    # The rule ties the listener to the backend pool
    $rule = New-AzApplicationGatewayRequestRoutingRule -Name 'itsm-routing-rule' `
        -RuleType 'Basic' `
        -HttpListener $listener `
        -BackendAddressPool $backendPool `
        -BackendHttpSettings $httpSettings

    # 7. Create the Web Application Firewall (WAF) Policy
    Write-Host "Creating WAF policy..."
    $wafPolicy = New-AzApplicationGatewayFirewallPolicy -Name $wafPolicyName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Mode 'Prevention'

    # 8. Create the Application Gateway Resource
    # This command assembles all the previous components.
    Write-Host "Deploying Application Gateway. This will take 15-30 minutes..."
    $appGatewaySku = New-AzApplicationGatewaySku -Name 'WAF_v2' -Tier 'WAF_v2' -Capacity 2

    New-AzApplicationGateway -Name $appGatewayName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Sku $appGatewaySku `
        -FirewallPolicy $wafPolicy `
        -VirtualNetwork $virtualNetwork `
        -Subnet $appGatewaySubnet `
        -FrontendIPConfigurations $frontendIpConfig `
        -BackendAddressPools $backendPool `
        -BackendHttpSettingsCollection $httpSettings `
        -HttpListeners $listener `
        -RequestRoutingRules $rule `
        -Probes $probe

    Write-Host "Application Gateway '$appGatewayName' deployed successfully!"
}

<#
================================================================================
Script:         Set-SQLPrivateEndpoint.ps1
Description:    This script secures an existing Azure SQL Server by disabling
                public network access and creating a private endpoint within a
                specified virtual network subnet.
================================================================================
#>

# --- Configuration Variables ---
# !! Fill in these values with your actual Azure resource names !!

$resourceGroupName = "DR-HelpDesk-RG"
$location = "EastUS" # Must be the same region as your VNet and SQL Server
$vnetName = "DR-HelpDesk-VNet"
$databaseSubnetName = "Database-Subnet"

# The name of your existing Azure SQL Server (the logical server, not the database itself)
#$sqlServerName = "your-sql-server-name"

# --- Script Execution ---

# 1. Get the existing virtual network and the specific subnet for the database
Write-Host "Fetching VNet and Subnet details for '$vnetName'..."
$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $databaseSubnetName -VirtualNetwork $virtualNetwork

# 2. Get the existing Azure SQL Server resource
Write-Host "Fetching Azure SQL Server details for '$sqlServerName'..."
$sqlServer = Get-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlServerName

# 3. Disable Public Network Access on the SQL Server
# This is a critical security step. It ensures the only access path is the private one.
Write-Host "Disabling public network access on '$sqlServerName'..."
Set-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -PublicNetworkAccess "Disabled"
Write-Host "✅ Public access disabled successfully."

# 4. Define the Private Endpoint and its connection
# A 'Private Link Service Connection' tells the endpoint what it's connecting to.
$privateLinkServiceConnection = New-AzPrivateLinkServiceConnection `
    -Name "$sqlServerName-Pls-connection" `
    -PrivateLinkServiceId $sqlServer.Id `
    -GroupId "sqlServer" # This specific GroupId tells Azure you're connecting to a SQL Server resource

# 5. Create the Private Endpoint resource
# This command provisions the network interface in your subnet and links it to the SQL server.
Write-Host "Creating the private endpoint..."
$privateEndpointName = "$sqlServerName-private-endpoint"
New-AzPrivateEndpoint -Name $privateEndpointName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Subnet $subnet `
    -PrivateLinkServiceConnection $privateLinkServiceConnection

Write-Host "✅ Private endpoint '$privateEndpointName' created successfully. Your database is now secured within your VNet."

