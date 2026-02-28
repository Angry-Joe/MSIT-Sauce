<#
Excellent. This is the final major infrastructure piece. The Application Gateway will act as the "front door" to your application. It provides a stable public endpoint, distributes traffic, and, most importantly, protects your web app with a Web Application Firewall (WAF).

This script is more complex than the previous ones because an Application Gateway has many interconnected components. We will create all of them and then assemble them into the final gateway resource.

Step 5 (PowerShell): Create and Configure the Application Gateway
This script will:

Create a new, dedicated subnet for the Application Gateway (this is a requirement).

Provision a public IP address for the gateway.

Create a WAF policy to protect against common web attacks.

Configure all the internal components: frontend IP, backend pool (pointing to your web app), HTTP settings, listener, and routing rule.

Deploy the Application Gateway itself.

Note: Application Gateway deployment is a lengthy process and can often take 15-30 minutes to complete.

Your Architecture is Complete!
Congratulations! After running this final script, you will have a complete, secure, and robust architecture deployed entirely through code:
    Internet traffic flows to the Application Gateway.
    The WAF inspects the traffic for threats and blocks malicious requests.
    Legitimate traffic is forwarded to your App Service (web app).
    Your App Service communicates with the Azure SQL Database privately and securely through its VNet connection and the database's private endpoint.
    You can securely manage any VMs in the environment using the Azure Bastion host.

Your next steps would be to configure a custom domain and HTTPS on the Application Gateway, and then deploy your application code to the App Service. You have built an outstanding foundation to work from.
#>

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
