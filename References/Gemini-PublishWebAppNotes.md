Of course. Now that the entire cloud infrastructure is built, the final step is to get your actual application code running on the App Service.

There are several ways to deploy your code, ranging from simple manual uploads to fully automated professional workflows. I'll outline the three most common and recommended methods.

---
### Method 1: Deploy from Visual Studio Code (Easiest for Development)

This is the most straightforward method if you are using Visual Studio Code as your editor. It provides a graphical interface to deploy your project directly to Azure.

#### Prerequisites
*   [Visual Studio Code](https://code.visualstudio.com/) installed.
*   The [Azure Tools for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-azure-tools) extension installed.

#### Steps
1.  **Sign in to Azure**: Open VS Code, go to the Azure extension in the activity bar (the Azure icon), and sign in to your Azure account.
2.  **Open Your Project**: Open the folder containing your web application code in VS Code.
3.  **Find Your App Service**: In the Azure extension pane, expand your subscription and find the App Service resource you created (e.g., `itsm-webapp-xxxx`).
4.  **Deploy**: Right-click on the App Service name and select **"Deploy to Web App..."**.
5.  **Confirm**: A prompt will appear asking you to confirm the deployment from your current project folder. Click **"Deploy"**.

VS Code will package your application, upload it, and restart the App Service with your new code. You can watch the progress in the output window.

---
### Method 2: Continuous Deployment with Git (Best Practice for Production)

This method, often called CI/CD (Continuous Integration/Continuous Deployment), automatically deploys your code whenever you push changes to a specific branch of a Git repository (like `main`). This is the standard for professional development.

#### Steps
1.  **Push Code to GitHub**: Make sure your web application code is in a GitHub repository.
2.  **Navigate to Deployment Center**: In the Azure Portal, go to your App Service resource. In the left-hand menu, under "Deployment", click on **Deployment Center**.
3.  **Configure Source**:
    *   For the "Source", select **GitHub**.
    *   Authorize Azure to access your GitHub account if prompted.
    *   Choose the **Organization**, **Repository**, and **Branch** that contains your code.
4.  **Save Configuration**: Click **Save**.

Azure will automatically create a **GitHub Actions workflow file** (`.yml`) in your repository. This file contains the instructions to build and deploy your app. The first deployment will start immediately, and any future `git push` to your chosen branch will automatically trigger a new deployment.

---
### Method 3: Deploy with PowerShell (For Scripting and Automation)

Since we've been using PowerShell for everything else, you can also use it to deploy your application. This is great for including deployment in a larger automation script.

This command works by zipping your local project folder and pushing the zip file to the App Service.

#### Steps
1.  **Prepare a ZIP file**: First, create a `.zip` file of all your application's code and files. Make sure the files are at the root of the zip file, not inside a parent folder.
2.  **Run the PowerShell Script**:

```powershell
# --- Configuration Variables ---
$resourceGroupName = "YourResourceGroupName"
$webAppName = "your-unique-webapp-name" # The name of your App Service
$zipFilePath = "C:\path\to\your_application.zip" # The local path to your zipped code


# --- Script Execution ---

Write-Host "Deploying application from '$zipFilePath' to App Service '$webAppName'..."

Publish-AzWebApp -ResourceGroupName $resourceGroupName `
    -Name $webAppName `
    -ArchivePath $zipFilePath

Write-Host "Deployment completed successfully."
```

| Command | Purpose |
| :--- | :--- |
| **`Publish-AzWebApp`** | This is the dedicated command for deploying code to an App Service. It handles the process of uploading the archive (`-ArchivePath`) and correctly deploying its contents to the live environment. |

Choose the method that best fits your workflow. For active development and quick tests, the VS Code extension is fantastic. For a serious, long-term project, setting up the GitHub Actions CI/CD pipeline is highly recommended.
