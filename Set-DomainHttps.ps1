<# Of course. Configuring a custom domain with HTTPS is a critical step to make your application professional and secure for your customers. This process involves uploading your SSL certificate to the Application Gateway and then telling the gateway to use it for traffic to your custom domain.

---
### Prerequisites: What You Need First

Before running the PowerShell script, you absolutely must have the following two items:

1.  **A Custom Domain Name**: You must own a domain name purchased from a registrar (e.g., GoDaddy, Namecheap, Cloudflare).
2.  **An SSL/TLS Certificate**: You need an SSL certificate for your custom domain in the **`.pfx` format**, which includes both the public certificate and the private key.
    *   You can purchase a certificate from a commercial Certificate Authority (CA).
    *   For testing, you can generate a self-signed certificate, but users will see a browser warning.
    *   You will need the **password** used to export the `.pfx` file.

---
### Step A: Update Your DNS Records

Before configuring the gateway, you must point your custom domain's DNS to the Application Gateway.

1.  **Find your Application Gateway's Public IP Address**: #>

    # Run this to get the IP address or DNS Name of your App Gateway
    $resourceGroupName = "YourResourceGroupName"
    $publicIpName = "itsm-appgateway-pip"
    Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $publicIpName | Select-Object IpAddress,Fqdn

<# 
2.  **Create a DNS Record**: Go to your domain registrar's DNS management portal. Create a **`CNAME`** record that points your desired hostname (e.g., `www.your-itsm-app.com`) to the **`Fqdn`** (Fully Qualified Domain Name) from the command above. Using a `CNAME` is generally preferred over an `A` record with the IP address, as the FQDN will not change.

**Note**: DNS changes can take some time to propagate across the internet.

---
### Step B (PowerShell): Configure Custom Domain and HTTPS

This script will modify your existing Application Gateway. It will upload your SSL certificate, create a new listener for HTTPS traffic on port 443, and bind it all together.

Update the variables, especially the path to your `.pfx` file and its password.
 #>

# --- Configuration Variables ---
$resourceGroupName = "YourResourceGroupName"
$appGatewayName = "itsm-appgateway"

# !! Update these with your custom domain and certificate details !!
$customDomainName = "www.your-itsm-app.com" # The exact hostname you want to use
$pfxFilePath = "C:\path\to\your_certificate.pfx" # The local path to your SSL certificate
$pfxPassword = "Your_PFX_File_Password" # The password for the PFX file


# --- Script Execution ---

# 1. Get the existing Application Gateway configuration from Azure
Write-Host "Fetching existing Application Gateway: '$appGatewayName'..."
$appGateway = Get-AzApplicationGateway -Name $appGatewayName -ResourceGroupName $resourceGroupName

# 2. Add the SSL Certificate to the Application Gateway
# This securely uploads your PFX file and its password.
Write-Host "Uploading SSL certificate..."
$sslCertName = "itsm-ssl-cert"
Add-AzApplicationGatewaySslCertificate -ApplicationGateway $appGateway `
    -Name $sslCertName `
    -CertificateFile $pfxFilePath `
    -Password $pfxPassword

# 3. Update the HTTP Listener to use HTTPS
# We will modify the existing listener to switch it from HTTP:80 to HTTPS:443
Write-Host "Updating listener for HTTPS..."
Set-AzApplicationGatewayHttpListener -ApplicationGateway $appGateway `
    -Name 'itsm-http-listener' `
    -Protocol 'Https' `
    -FrontendPort 443 `
    -SslCertificate $sslCertName `
    -HostName $customDomainName # Tells the listener to only respond to requests for this hostname

# 4. RECOMMENDED: Configure HTTP-to-HTTPS Redirection
# This adds a new listener and rule to automatically redirect users from http:// to https://
Write-Host "Configuring HTTP-to-HTTPS redirection..."

# Add a new listener for HTTP traffic on port 80
$redirectListenerName = "itsm-redirect-listener"
Add-AzApplicationGatewayHttpListener -ApplicationGateway $appGateway `
    -Name $redirectListenerName `
    -Protocol 'Http' `
    -FrontendIPConfiguration $appGateway.FrontendIPConfigurations[0] `
    -FrontendPort 80 `
    -HostName $customDomainName

# Create the redirection configuration
$redirectConfigName = "itsm-redirect-config"
Add-AzApplicationGatewayRedirectConfiguration -ApplicationGateway $appGateway `
    -Name $redirectConfigName `
    -RedirectType 'Permanent' `
    -TargetListener $appGateway.HttpListeners.Where({$_.Name -eq 'itsm-http-listener'})[0] `
    -IncludePath $true `
    -IncludeQueryString $true

# Create a new routing rule for the redirection
$redirectRuleName = "itsm-redirect-rule"
Add-AzApplicationGatewayRequestRoutingRule -ApplicationGateway $appGateway `
    -Name $redirectRuleName `
    -RuleType 'Basic' `
    -HttpListener $appGateway.HttpListeners.Where({$_.Name -eq $redirectListenerName})[0] `
    -RedirectConfiguration $appGateway.RedirectConfigurations.Where({$_.Name -eq $redirectConfigName})[0]

# 5. Commit all the changes back to Azure
# This command applies all the in-memory changes to the live Application Gateway.
# This step can take a few minutes.
Write-Host "Applying all changes to the Application Gateway. This may take a few minutes..."
Set-AzApplicationGateway -ApplicationGateway $appGateway

Write-Host "Application Gateway configuration updated successfully for '$customDomainName'."
```

### Verification

Once the script completes and your DNS has propagated, you should be able to:
1.  Navigate to `https://your-custom-domain.com` in a web browser.
2.  See your deployed application.
3.  See a lock icon in the address bar, indicating a secure HTTPS connection using your certificate.
4.  If you try to go to `http://your-custom-domain.com`, you should be automatically redirected to the `https://` version.
