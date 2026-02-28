<#
Source: Gemini Enterprise
This script performs three main actions:

Creates an App Service Plan, which is the underlying compute resource (the server farm) for your web app.

Creates the Web App (an App Service instance) on that plan.

Configures VNet Integration to connect the web app to your WebApp-Subnet.

Important: The name for your web app ($webAppName) must be globally unique across all of Azure, as it forms part of the URL (your-name.azurewebsites.net).

You're Almost There!
You have now built a solid, secure, and scalable foundation for your project:

A Virtual Network to isolate your resources.

A secured SQL Database accessible only from within the VNet.

A Bastion Host for secure administrative access.

An App Service for your web app, integrated into the VNet so it can reach the database.

The next major piece of the puzzle is managing the public traffic to your web app. For that, we'll need to set up an Application Gateway.

Would you like to proceed with the PowerShell script to create and configure an Azure Application Gateway? This will act as your load balancer and Web Application Firewall (WAF).
#>

# --- Configuration Variables ---
$resourceGroupName = "YourResourceGroupName"
$location = "EastUS" # Must be the same region as your VNet
$vnetName = "ITSM-VNet"
$webAppSubnetName = "WebApp-Subnet"

# --- App Service Variables ---
# The App Service Plan SKU must support VNet Integration (e.g., Basic, Standard, Premium). 'P1v2' is a good start.
$appServicePlanName = "itsm-asp"
$appServicePlanSku = "P1v2"

# !! IMPORTANT: Change this to a globally unique name !!
$webAppName = "itsm-webapp-$(Get-Random)" # Using Get-Random for demonstration. Choose a meaningful unique name.


# --- Script Execution ---

# 1. Create the App Service Plan
Write-Host "Creating App Service Plan '$appServicePlanName'..."
New-AzAppServicePlan -Name $appServicePlanName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Tier $appServicePlanSku

Write-Host "App Service Plan created successfully."

# 2. Create the Web App
Write-Host "Creating Web App '$webAppName'..."
New-AzWebApp -Name $webAppName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AppServicePlan $appServicePlanName

Write-Host "Web App created successfully."

# 3. Configure VNet Integration
# This step enables the web app to send outbound traffic into your VNet.
Write-Host "Configuring VNet Integration for '$webAppName'..."

# Get the full resource ID of the subnet
$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnetId = $virtualNetwork.Subnets.Where({ $_.Name -eq $webAppSubnetName }).Id

# Set the VNet integration on the web app
Set-AzWebApp -ResourceGroupName $resourceGroupName `
    -Name $webAppName `
    -VirtualNetworkSubnetId $subnetId

Write-Host "VNet Integration configured successfully. Your web app can now communicate with resources in '$vnetName'."
