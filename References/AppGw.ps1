<#
================================================================================
Script:         Deploy-AppGateway.ps1
Description:    Assembles all required configuration objects and creates the
                Azure Application Gateway. This script follows the current
                Az.Network module best practices.
================================================================================
#>

# --- Step 1: Create the Gateway's IP Configuration ---
# This links the gateway to its dedicated subnet. This is a crucial step
# that was missing and incorrect in the previous version.
Write-Host "Creating the Gateway IP Configuration..."
$gatewayIpConfig = New-AzApplicationGatewayIPConfiguration -Name 'appGatewayIpConfig' -Subnet $appGatewaySubnet
Write-Host "✅ Gateway IP Configuration created."


# --- Step 2: Create the Frontend IP Configuration ---
# This links the public IP address to the gateway's frontend.
Write-Host "Creating the Frontend IP Configuration..."
$frontendIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name 'appGatewayFrontendIP' -PublicIPAddress $publicIp
Write-Host "✅ Frontend IP Configuration created."


# --- Step 3: Get the ID of the WAF Policy ---
# The New-AzApplicationGateway command requires the ID of the WAF policy, not the full object.
$wafPolicyId = $wafPolicy.Id


# --- Step 4: Assemble and Deploy the Application Gateway ---
# This final command brings all the configuration pieces together.
# Notice how we pass arrays of objects for each configuration type.

Write-Host "⏳ Deploying Application Gateway. This will take 15-30 minutes..."

New-AzApplicationGateway -Name $appGatewayName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Sku (New-AzApplicationGatewaySku -Name 'WAF_v2' -Tier 'WAF_v2') `
    -GatewayIPConfigurations $gatewayIpConfig `
    -WebApplicationFirewallConfiguration (New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Prevention" -RuleSetType "OWASP" -RuleSetVersion "3.2")`
    #-FirewallPolicyId $wafPolicyId `
    -FirewallPolicyId $wafPolicy.Id `
    -FrontendIPConfigurations $frontendIpConfig `
    -FrontendPorts (New-AzApplicationGatewayFrontendPort -Name 'appGatewayFrontendPort' -Port 80) `
    -BackendAddressPools $backendPool `
    -BackendHttpSettingsCollection $httpSettings `
    -HttpListeners $listener `
    -RequestRoutingRules $rule `
    -Probes $probe

Write-Host "🎉 Application Gateway '$appGatewayName' deployed successfully!"
