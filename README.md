# MSIT-Sauce

Repo for projects I'm doing for my master's degree.

## TODO

-Add Entra External ID service to subscription to set up customer logins

## Scope

The first objective in Sauce is to build an IT Service Management solution in Azure Cloud. I intend on  using this app in production on my business's web site. I want a customer login, and once authenticated, have access to a 'Help Desk System' where they can ask for help or request resources. I intend on writing in code to help keep track of Service Level Agreements and hot issues. There are a thousand products out there,m but I'm cheap and I love to code so I'm making my own.

[IT Service Management module (Web App)](http://drhelpdesk-testwebapp.azurewebsites.net)  
[Azure Functions](https://drhelpdeskfunc-gtazfzathpg6fma0.eastus-01.azurewebsites.net/api/GetSqlData)

### Products/Services included in Project

    Virtual Network
    App Service Plan
    Azure Bastion Host
    Azure Storage Accounts
    Load Balancer
    Application Gateway
    DNS Zones
    Azure SQL Server and Database
    Web Application Firewall
    Web application itself
    Entra ID
    Entra External ID
    Azure Communication Services (Pipe dream, but worth a shot)

## Requirements

- Azure Functions Core Tools CLI: <https://go.microsoft.com/fwlink/?linkid=2174087>  
- EF Core Power Tools CLI: <https://marketplace.visualstudio.com/items?itemName=ErikEJ.EFCorePowerTools>  

### References

- [Azure App Service explained](https://learn.microsoft.com/en-us/azure/app-service/overview)
- <https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration>
- <https://learn.microsoft.com/en-us/azure/app-service/configure-vnet-integration-routing>
- <https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#website_vnet_route_all>

### External login providers  

- <https://learn.microsoft.com/en-us/aspnet/core/security/authentication/social/?view=aspnetcore-10.0&tabs=visual-studio>

- <https://learn.microsoft.com/en-us/aspnet/core/security/authentication/social/additional-claims?view=aspnetcore-10.0>

- [Host a web application with Azure App Service - Training | Microsoft Learn](https://learn.microsoft.com/en-us/training/modules/host-a-web-app-with-azure-app-service/?source=recommendations)
- [Quickstart: Direct web traffic using PowerShell - Azure Application Gateway | Microsoft Learn](https://learn.microsoft.com/en-us/azure/application-gateway/quick-create-powershell)
