<#
    TODO
    Add Entra External ID for customers
    Integrate employee Entra IDs to ITSM


#># This is the order the scripts should run to build the project soup-to-nuts
### GLOBALS ###
$rgName                 = "DR-HelpDesk-RG"
$location               = "EastUS"
$vnetName               = "DR-HelpDesk-VNet"
$vnetAddressPrefix      = "10.0.0.0/16"

# Work in progress. This should be a loop to generate subnet configs for all that gets passed into VNet creation
$subnets = @(
    @{ Name="WebApp-Subnet";      AddressPrefix="10.0.1.0/24" },
    @{ Name="Database-Subnet";    AddressPrefix="10.0.2.0/24" },
    @{ Name="AzureBastionSubnet"; AddressPrefix="10.0.3.0/26" },
    @{ Name="WebAppTest-Subnet";  AddressPrefix="10.0.5.0/24" }
    @{ Name="AppGateway-Subnet";  AddressPrefix="10.0.4.0/24" },
)

$subnets = @(
    @{ Name="WebApp-Subnet";      AddressPrefix="10.0.10.0/24" },
    @{ Name="Database-Subnet";    AddressPrefix="10.0.11.0/24" },
    @{ Name="AzureBastionSubnet"; AddressPrefix="10.0.12.0/26" },
    @{ Name="WebAppTest-Subnet";  AddressPrefix="10.0.13.0/24" }
    @{ Name="AppGateway-Subnet";  AddressPrefix="10.0.14.0/24" },
)

$databaseSubnetName     = "Database-Subnet"
$sqlServerName          = "dr-helpdesk-sql-2026"
$pvtEndpointName        = "sqlep-itsm-01" # A name for the new private endpoint resource
$pvtLinkConnName        = "sqlConnection-itsm-01" # A name for the connection within the endpoint

$bastionHostName        = "Dr-helpdesk-bastion-host"
$publicIpName           = "Dr-helpdesk-bastion-pip" # Name for the Bastion's Public IP address

$appServicePlanName     = "ASP-DRHelpDeskRG-b824"
$webAppName             = "drhelpdesk-webapp" # Must be globally unique across Azure
$webAppSubnetName       = "WebApp-Subnet"
$webAppPIPName          = "dr-helpdesk-appgateway-pip"

$appGatewayName         = "dr-helpdesk-appgateway"
$appGatewaySubnetName   = "AppGatewaySubnet"
$wafPolicyName          = "dr-helpdesk-waf-policy"


$vnet   # Placeholder for VNet object to be used across functions. Created in New-VNet function.

# Create virtual network and subnets
function New-VNet {
    # --- Configuration Variables ---
    #$vnetAddressPrefix = "10.0.0.0/16"

    # --- Subnet Definitions ---
    $appParms       = @{ Name="WebApp-Subnet";      AddressPrefix="10.0.1.0/24" }
    $dbParms        = @{ Name="Database-Subnet";    AddressPrefix="10.0.2.0/24" }
    $bastionParms   = @{ Name="AzureBastionSubnet"; AddressPrefix="10.0.3.0/26" }
    $appGWParms     = @{ Name="AppGateway-Subnet";  AddressPrefix="10.0.4.0/24" }

    # Create the Subnet Configuration Objects in memory
    $webAppSubnet   = New-AzVirtualNetworkSubnetConfig @appParms
    $databaseSubnet = New-AzVirtualNetworkSubnetConfig @dbParms
    $bastionSubnet  = New-AzVirtualNetworkSubnetConfig @bastionParms
    $appGWSubnet    = New-AzVirtualNetworkSubnetConfig @appGWParms

    # Create the Virtual Network in Azure with the defined subnets
    $vnet = New-AzVirtualNetwork `
        -Name $vnetName `
        -ResourceGroupName $rgName `
        -Location $location `
        -AddressPrefix $vnetAddressPrefix `
        -Subnet $webAppSubnet, $databaseSubnet, $bastionSubnet, $appGWSubnet

    Return $vnet

    Write-Information "Virtual Network '$vnetName' and its subnets have been created successfully." -InformationAction Continue
}
$vnet = New-VNet

# Secure Azure SQL Database - disables public access and creates a private endpoint.
function Set-AzDBNetSecurityOptions {
    # --- Configuration Variables ---
    #$rgName = "YourRGName"
    #$location = "EastUS" # Must be the same region as your VNet
    #$vnetName = "YourVnetName"
    #$databaseSubnetName = "Database-Subnet"
    #$sqlServerName = "YourSqlServerName" # The name of your existing Azure SQL Server
    #$pvtEndpointName = "sqlep-itsm-01" # A name for the new private endpoint resource
    #$pvtLinkConnName = "sqlConnection-itsm-01" # A name for the connection within the endpoint

    <#
    Verification
    After running the script, a Private DNS Zone named privatelink.database.windows.net will be automatically created in your resource group. This is how your web app will be able to resolve your database's standard hostname (e.g., yourserver.database.windows.net) to its new private IP address within the VNet.

    You have now taken a massive step in securing your application architecture! What would you like to build next? We could proceed with scripting the Azure Bastion host for secure management access.

    #>
    # --- Configuration Variables ---
    # !! Fill these in with your existing resource names !!
    #$rgName = "YourResourceGroupName"
    #$location = "EastUS" # Must be the same region as your VNet
    #$vnetName = "ITSM-VNet"
    #$databaseSubnetName = "Database-Subnet"

    #$sqlServerName = "YourSqlServerName" # The name of your existing Azure SQL Server
    #$pvtEndpointName = "sqlep-itsm-01" # A name for the new private endpoint resource
    #$pvtLinkConnName = "sqlConnection-itsm-01" # A name for the connection within the endpoint


    # --- Script Execution ---

    # 1. Get the existing virtual network and the specific subnet for the database
    Write-Host "Fetching VNet and Subnet details..."
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $databaseSubnetName -VirtualNetwork $vnet

    # 2. Get the existing Azure SQL Server resource
    Write-Host "Fetching Azure SQL Server details..."
    $sqlServer = Get-AzSqlServer -ResourceGroupName $rgName -ServerName $sqlServerName

    # 3. Disable Public Network Access on the SQL Server
    Write-Host "Disabling public network access on '$sqlServerName'..."
    Set-AzSqlServer -ResourceGroupName $rgName `
        -ServerName $sqlServerName `
        -PublicNetworkAccess "Disabled"

    Write-Host "Public access disabled successfully."

    # 4. Create the Private Endpoint
    # This is a multi-step process: define the connection, then create the endpoint resource.

    # Define the connection to the SQL server
    $privateLinkServiceConnection = New-AzPrivateLinkServiceConnection -Name $pvtLinkConnName `
        -PrivateLinkServiceId $sqlServer.Id `
        -GroupId "sqlServer" # This specific GroupId tells Azure you're connecting to a SQL Server

    # Create the private endpoint resource in your database subnet
    Write-Host "Creating the private endpoint..."
    New-AzPrivateEndpoint -Name $pvtEndpointName `
        -ResourceGroupName $rgName `
        -Location $location `
        -Subnet $subnet `
        -PrivateLinkServiceConnection $privateLinkServiceConnection

    Write-Host "Private endpoint '$pvtEndpointName' created successfully. Your database is now secured."
}

# Deploy Azure Bastion for secure management access to network
# . .\New-AzureBastion.ps1
function New-AzureBastion {
    # --- Configuration Variables ---
    #$rgName = "DR-HelpDesk-RG"
    #$location = "EastUS" # Must be the same region as your VNet
    #$vnetName = "DR-HelpDesk-VNet"
    #$bastionHostName = "itsm-bastion-host"
    #$publicIpName = "itsm-bastion-pip" # Name for the Bastion's Public IP address

    # --- Script Execution ---
    # 1. Get the existing virtual network resource
    Write-Host "Fetching VNet details..."
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
    # 2. Create the Public IP Address for Azure Bastion
    # It MUST be a 'Standard' SKU and 'Static' allocation.
    Write-Host "Creating a standard public IP address for Bastion..."
    $publicIp = New-AzPublicIpAddress -ResourceGroupName $rgName `
        -Name $publicIpName `
        -Location $location `
        -AllocationMethod 'Static' `
        -Sku 'Standard'
    # 3. Create the Azure Bastion Host
    # This command links the Bastion service to your VNet and the Public IP.
    Write-Host "Deploying Azure Bastion host. This may take 5-10 minutes..."
    New-AzBastion -ResourceGroupName $rgName `
        -Name $bastionHostName `
        -PublicIpAddress $publicIp `
        -VirtualNetwork $vnet
    Write-Host "Azure Bastion host '$bastionHostName' deployed successfully."
}

# Crate App Service Plan - this is what allows the app to talk to SQL DB
# . .\New-AzureAppService.ps1
function New-AzureApp {
    # Create the App Service Plan
    Write-Host "Creating App Service Plan '$appServicePlanName'..."
    New-AzAppServicePlan `
        -Name $appServicePlanName `
        -ResourceGroupName $rgName `
        -Location $location `
        -Tier "Standard" `
        -WorkerSize 1
    Write-Host "App Service Plan '$appServicePlanName' created successfully."

    # Create the Web App and integrate it with the VNet
    Write-Host "Creating Web App '$webAppName' and integrating with VNet..."
    $webApp = New-AzWebApp `
        -Name $webAppName `
        -ResourceGroupName $rgName `
        -Location $location `
        -AppServicePlan $appServicePlanName

    Write-Information "Web App '$webAppName' created. Now configuring VNet integration..." -InformationAction Continue
    # This needs to be tested. How long after previous command can we set properties?
    # Enable "Route All" in the Web App's configuration to ensure all traffic goes through the VNet.
    $webApp = Get-AzWebApp -ResourceGroupName $rgName -Name $webAppName
    $webApp.SiteConfig.VnetRouteAllEnabled = $true
    Set-AzWebApp -WebApp $webApp

    Restart-AzWebApp -ResourceGroupName $rgName -Name $webAppName

    # Get the existing virtual network and subnet for integration
    #$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $webAppSubnetName -VirtualNetwork $vnet

    # Apply the new subnet to your Virtual Network in Azure
    #$vnet | Set-AzVirtualNetwork

    # Create a Public IP for the Gateway
    $publicIP = New-AzPublicIpAddress `
        -ResourceGroupName $rgName `
        -Name $webAppPIPName `
        -Location $location `
        -AllocationMethod 'Static' `
        -Sku 'Standard'

    Write-Host "Web App '$webAppName' created and integrated with VNet successfully."

    Return $publicIp
}
$appGWPip = New-AzureApp

# Create and configure the App Gateway (pub endpoint, traffic distro, web app firewall)
# . .\New-ProjectAppGateway.ps1
function New-ProjectAppGateway {
    # Refresh VNet variable to get the newly created subnet object
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
    $appGatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name $appGatewaySubnetName -VirtualNetwork $vnet

    # --- Script Execution ---

    # Refresh VNet variable to get the new subnet object
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
    $appGatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name $appGatewaySubnetName -VirtualNetwork $vnet

    #$appGWPip = Get-AzPublicIpAddress -ResourceGroupName $rgName -Name $webAppPIPName

    # 3. Create the Gateway's IP Configuration
    Write-Host "Configuring frontend IP..."
    $frontendIpConfig = New-AzApplicationGatewayFrontendIPConfig `
        -Name 'appGatewayFrontendIP' `
        -PublicIPAddress $appGWPip

    # 4. Create the Backend Address Pool (pointing to your App Service)
    Write-Host "Configuring backend address pool..."
    $webAppFqdn = (Get-AzWebApp -Name $webAppName -ResourceGroupName $rgName).DefaultHostName
    $backendPool = New-AzApplicationGatewayBackendAddressPool -Name 'dr-helpdesk-webapp-backend-pool' `
        -BackendFqdns $webAppFqdn

    # 5. Create the HTTP Settings and Health Probe
    Write-Host "Configuring HTTP settings and health probe..."
    # The health probe checks the health of your web app
    $probe = New-AzApplicationGatewayProbeConfig `
        -Name 'dr-webapp-probe' `
        -Protocol 'Http' `
        #-HostName $webAppFqdn `
        -Path '/' `
        -Interval 30 `
        -Timeout 30 `
        -UnhealthyThreshold 3
        -PickHostNameFromBackendHttpSettings

    # The HTTP settings define how the gateway talks to the backend
    $httpSettings = New-AzApplicationGatewayBackendHttpSettings `
        -Name 'dr-webapp-http-settings' `
        -Port 80 `
        -Protocol 'Http' `
        -CookieBasedAffinity 'Disabled' `
        -Probe $probe `
        -RequestTimeout 30
        -PickHostNameFromBackendAddress $true

    # 6. Create the Frontend Listener and Routing Rule
    Write-Host "Configuring listener and routing rule..."
    # The listener waits for incoming traffic on Port 80
    $frontendPort = New-AzApplicationGatewayFrontendPort -Name 'appGatewayFrontendPort' -Port 80

    $listener = New-AzApplicationGatewayHttpListener -Name 'dr-webapp-http-listener' `
        -Protocol 'Http' `
        -FrontendIPConfiguration $frontendIpConfig `
        -FrontendPort $frontendPort  # <-- Use the object here instead of the number 80

    # The rule ties the listener to the backend pool
    $rule = New-AzApplicationGatewayRequestRoutingRule -Name 'dr-webapp-routing-rule' `
        -RuleType 'Basic' `
        -HttpListener $listener `
        -BackendAddressPool $backendPool `
        -BackendHttpSettings $httpSettings

    # 7. Create the Web Application Firewall (WAF) Policy
    Write-Host "Creating WAF policy..."
    $wafPolicy = New-AzApplicationGatewayFirewallPolicy `
        -Name $wafPolicyName `
        -ResourceGroupName $rgName `
        -Location $location `

    # Update the 'Mode' setting on the policy object in PowerShell
    $wafPolicy.PolicySettings.Mode = "Prevention"

    # Apply the change back to the policy resource in Azure
    Set-AzApplicationGatewayFirewallPolicy -InputObject $wafPolicy

    # 8. Create the Application Gateway Resource
    # This command assembles all the previous components.
    Write-Host "Deploying Application Gateway. This will take 15-30 minutes..."

    $appGatewaySku = New-AzApplicationGatewaySku -Name 'WAF_v2' -Tier 'WAF_v2' -Capacity 2
    $gatewayIpConfig = New-AzApplicationGatewayIPConfiguration -Name 'appGatewayIpConfig' -Subnet $appGatewaySubnet
    $frontendIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name 'appGatewayFrontendIP' -PublicIPAddress $appGWPip
    $wafConfig = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Prevention" -RuleSetType "OWASP" -RuleSetVersion "3.2"

        # --- Configuration Variables ---
    # Ensure these are set correctly from our previous steps
    $resourceGroupName = "DR-HelpDesk-RG"
    $location = "EastUS"
    $vnetName = "DR-HelpDesk-VNet"
    $webAppName = "drhelpdesk-webapp"
    $appGatewaySubnetName = "AppGatewaySubnet"
    $appGatewayName = "dr-helpdesk-appgateway"
    $publicIpName = "dr-helpdesk-appgateway-pip"
    $wafPolicyName = "dr-helpdesk-waf-policy"
    $fqdn = "drhelpdesk-webapp.azurewebsites.net"
<#
    # --- Re-gather Azure Objects to Ensure They Are Correct ---
    Write-Host "Gathering required Azure resources..."
    $appGatewaySubnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName | Get-AzVirtualNetworkSubnetConfig -Name $appGatewaySubnetName
    $publicIp = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName
    $wafPolicy = Get-AzApplicationGatewayFirewallPolicy -Name $wafPolicyName -ResourceGroupName $resourceGroupName

    # --- Step 1: Define All Configuration Objects ---
    Write-Host "Defining Application Gateway configuration objects..."

    $gatewayIpConfig = New-AzApplicationGatewayIPConfiguration -Name 'appGatewayIpConfig' -Subnet $appGatewaySubnet
    $frontendIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name 'appGatewayFrontendIP' -PublicIPAddress $publicIp
    $frontendPort = New-AzApplicationGatewayFrontendPort -Name 'appGatewayFrontendPort' -Port 80
    $webAppFqdn = (Get-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName).DefaultHostName
    $backendPool = New-AzApplicationGatewayBackendAddressPool -Name 'itsm-backend-pool' -BackendFqdns $webAppFqdn
    $probe = New-AzApplicationGatewayProbeConfig -Name 'itsm-probe' -Protocol 'Http' -HostName $webAppFqdn -Path '/' -Interval 30 -Timeout 30 -UnhealthyThreshold 3
    $httpSettings = New-AzApplicationGatewayBackendHttpSettings -Name 'itsm-http-settings' -Port 80 -Protocol 'Http' -CookieBasedAffinity 'Disabled' -Probe $probe -RequestTimeout 30
    $listener = New-AzApplicationGatewayHttpListener -Name 'itsm-http-listener' -Protocol 'Http' -FrontendIPConfiguration $frontendIpConfig -FrontendPort $frontendPort
    $rule = New-AzApplicationGatewayRequestRoutingRule -Name 'itsm-routing-rule' -RuleType 'Basic' -Priority 100 -HttpListener $listener -BackendAddressPool $backendPool -BackendHttpSettings $httpSettings
    $appGatewaySku = New-AzApplicationGatewaySku -Name 'WAF_v2' -Tier 'WAF_v2' -Capacity 2

    # --- Step 2: Assemble and Deploy the Application Gateway ---
    Write-Host "⏳ Assembling configuration and deploying Application Gateway. This will take 15-30 minutes..."
#>
    New-AzApplicationGateway -Name $appGatewayName `
        -ResourceGroupName $rgName `
        -Location $location `
        -Sku $appGatewaySku `
        -GatewayIPConfigurations @($gatewayIpConfig) `
        -FirewallPolicy $wafPolicy `
        -FrontendIPConfigurations @($frontendIpConfig) `
        -FrontendPorts @($frontendPort) `
        -BackendAddressPools @($backendPool) `
        -BackendHttpSettingsCollection @($httpSettings) `
        -HttpListeners @($listener) `
        -RequestRoutingRules @($rule) `
        -Probes @($probe)

     <# Success!
        Output:
            PS C:\jdlcode> New-AzApplicationGateway -Name $appGatewayName `
            >>     -ResourceGroupName $resourceGroupName `
            >>     -Location $location `
            >>     -Sku $appGatewaySku `
            >>     -GatewayIPConfigurations @($gatewayIpConfig) `
            >>     -FirewallPolicy $wafPolicy `
            >>     -FrontendIPConfigurations @($frontendIpConfig) `
            >>     -FrontendPorts @($frontendPort) `
            >>     -BackendAddressPools @($backendPool) `
            >>     -BackendHttpSettingsCollection @($httpSettings) `
            >>     -HttpListeners @($listener) `
            >>     -RequestRoutingRules @($rule) `
            >>     -Probes @($probe)

            ResourceGroupName Name                   Location Sku Name Policy Name EnableHttp2 EnableFips ForceFirewallPolicyAssoci
                                                                                                          ation
            ----------------- ----                   -------- -------- ----------- ----------- ---------- -------------------------
            DR-HelpDesk-RG    dr-helpdesk-appgateway eastus   WAF_v2
     #>

    Write-Host "🎉 Application Gateway '$appGatewayName' deployed successfully!"
}

# Troubleshooting
New-AzAppServicePlan `
-Name "DRHelpDesk-TestAppServicePlan" `
-ResourceGroupName "DR-HelpDesk-RG" `
-Location "EastUS" `
-Tier "Standard" `
-WorkerSize 1

New-AzWebApp `
-Name "drhelpdesk-testwebapp" `
-ResourceGroupName "DR-HelpDesk-RG" `
-Location "EastUS" `
-AppServicePlan "DRHelpDesk-TestAppServicePlan"

Set-AzWebAppVnetRouteAllEnabled -ResourceGroupName "DR-HelpDesk-RG" -WebAppName "drhelpdesk-testwebapp" -VnetRouteAllEnabled $true
$virtualNetwork = Get-AzVirtualNetwork -Name "DR-HelpDesk-VNet" -ResourceGroupName "DR-HelpDesk-RG"
$subnet = Get-AzVirtualNetworkSubnetConfig -Name "WebApp-Subnet" -VirtualNetwork $virtualNetwork
Set-AzWebAppVnetIntegration -ResourceGroupName "DR-HelpDesk-RG" -WebAppName "drhelpdesk-testwebapp" -SubnetId $subnet.Id