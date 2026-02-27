<#
    TODO
    Add Entra External ID for customers
    Integrate employee Entra IDs to ITSM


#># This is the order the scripts should run to build the project soup-to-nuts

# Create virtual network and subnets
. .\New-Vnet.ps1

# Secure Azure SQL Database - disables public access and creates a private endpoint.
. .\Set-AzDBNetSecurityOptions.ps1

# Deploy Azure Bastion for secure management access to network
. .\New-AzureBastion.ps1

# Crate App Service Plan - this is what allows the app to talk to SQL DB
. .\New-AzureAppService.ps1

# Create and configure the App Gateway (pub endpoint, traffic distro, web app firewall)
. .\New-ProjectAppGateway.ps1
