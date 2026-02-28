Excellent question. This is a crucial step in building a professional ITSM application. Integrating with Microsoft Entra ID (formerly Azure Active Directory) is the correct and most secure way to manage your internal employees for ticket assignments.

You will **not** store your employees' passwords in your database. Instead, your application will trust Entra ID for authentication, and you will store a *reference* to the Entra user/group objects in your local database.

Here is the high-level strategy and the detailed implementation steps.

### High-Level Strategy

1.  **App Registration in Entra ID**: You will register your web application in Microsoft Entra ID. This gives your app an identity that can be granted permissions.
2.  **Grant API Permissions**: You'll give your app permission to read user and group information from your Entra ID tenant using the **Microsoft Graph API**.
3.  **Database Schema Changes**: You will add tables to your local database to store a local, synchronized copy of relevant user and group data (like Display Name, Email, and the all-important Entra Object ID).
4.  **Synchronization Process**: Your application will have a background process (or a manual trigger for an admin) that periodically syncs users and groups from Entra ID into your local database tables. This keeps your assignment lists up-to-date.
5.  **Application Logic**:
    *   The "Assigned To" and "Assignment Group" dropdowns in your app will be populated from your local database tables.
    *   When a technician logs into your ITSM app, they will use their Microsoft credentials ("Login with Microsoft").

---

### Step 1: Register an Application in Microsoft Entra ID

1.  Navigate to the **Microsoft Entra ID** service in the Azure Portal.
2.  Go to **App registrations** and click **"+ New registration"**.
3.  Give it a name (e.g., `ITSM-WebApp`).
4.  For "Supported account types," choose **"Accounts in this organizational directory only"**.
5.  You can skip the "Redirect URI" for now. Click **Register**.
6.  Once created, go to the **"Certificates & secrets"** tab. Create a **new client secret**. Copy the **Value** immediately and save it somewhere secure (like Azure Key Vault). You will need this for your app to authenticate.
7.  Go to the **"API permissions"** tab.
    *   Click **"+ Add a permission"**.
    *   Select **Microsoft Graph**.
    *   Select **Application permissions**.
    *   Search for and add the following permissions:
        *   `User.Read.All`: To read all user profiles.
        *   `Group.Read.All`: To read all group names and memberships.
    *   After adding them, you must click the **"Grant admin consent for [Your Tenant]"** button. This allows your application to use these permissions without a user being logged in.

### Step 2: Database Schema Changes (PowerShell)

Here is the PowerShell script to create the necessary tables for storing user and group information and to update your `Tickets` table.

```powershell
# --- Configuration ---
$sqlServerName = "your-sql-server-name.database.windows.net" # <-- UPDATE THIS
$databaseName = "your-database-name"                         # <-- UPDATE THIS
$sqlAdminUser = "your-sql-admin-username"                    # <-- UPDATE THIS

# --- Securely Get Credentials ---
Write-Host "Please enter the password for the SQL user '$sqlAdminUser':"
$password = Read-Host -AsSecureString

# --- Define the T-SQL Query for Entra Integration ---
$createQuery = @"
-- =============================================
-- 1. Create Users/Technicians Table
-- This table will store a local copy of your Entra ID employees.
-- =============================================
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) NOT NULL,
    EntraObjectID UNIQUEIDENTIFIER NOT NULL, -- The Object ID from Entra ID
    DisplayName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserID ASC),
    CONSTRAINT UQ_Users_EntraObjectID UNIQUE (EntraObjectID) -- Ensures no duplicate Entra users
);
CREATE NONCLUSTERED INDEX IX_Users_Email ON dbo.Users(Email);


-- =============================================
-- 2. Create Assignment Groups Table
-- This stores a local copy of your Entra ID groups.
-- =============================================
CREATE TABLE dbo.AssignmentGroups (
    AssignmentGroupID INT IDENTITY(1,1) NOT NULL,
    EntraGroupID UNIQUEIDENTIFIER NOT NULL, -- The Object ID from Entra ID for the group
    GroupName NVARCHAR(255) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_AssignmentGroups PRIMARY KEY CLUSTERED (AssignmentGroupID ASC),
    CONSTRAINT UQ_AssignmentGroups_EntraGroupID UNIQUE (EntraGroupID)
);


-- =============================================
-- 3. Create User-Group Membership Table (Many-to-Many)
-- Links users to the groups they are members of.
-- =============================================
CREATE TABLE dbo.UserGroupMemberships (
    UserID INT NOT NULL,
    AssignmentGroupID INT NOT NULL,

    CONSTRAINT PK_UserGroupMemberships PRIMARY KEY CLUSTERED (UserID, AssignmentGroupID),
    CONSTRAINT FK_UserGroupMemberships_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_UserGroupMemberships_AssignmentGroups FOREIGN KEY (AssignmentGroupID) REFERENCES dbo.AssignmentGroups(AssignmentGroupID) ON DELETE CASCADE
);


-- =============================================
-- 4. Alter the Tickets Table
-- Add columns for assigning tickets to users and groups.
-- =============================================
ALTER TABLE dbo.Tickets
ADD AssignedToUserID INT NULL;

ALTER TABLE dbo.Tickets
ADD AssignmentGroupID INT NULL;

ALTER TABLE dbo.Tickets
ADD CONSTRAINT FK_Tickets_AssignedToUser FOREIGN KEY (AssignedToUserID) REFERENCES dbo.Users(UserID);

ALTER TABLE dbo.Tickets
ADD CONSTRAINT FK_Tickets_AssignmentGroup FOREIGN KEY (AssignmentGroupID) REFERENCES dbo.AssignmentGroups(AssignmentGroupID);

GO
"@

# --- Execute the Query ---
try {
    Write-Host "Connecting to database '$databaseName'..."
    Invoke-Sqlcmd -ServerInstance $sqlServerName `
        -Database $databaseName `
        -Username $sqlAdminUser `
        -Password $password `
        -Query $createQuery `
        -SuppressProviderContextWarning
    Write-Host -ForegroundColor Green "Successfully updated database for Entra ID integration!"
} catch {
    Write-Host -ForegroundColor Red "An error occurred: $($_.Exception.Message)"
}
```

### Step 3: Application Logic for Synchronization

In your web application's code (e.g., using C# with ASP.NET), you will need to:

1.  **Use the Microsoft Authentication Library (MSAL)**: To get an application-only access token from Entra ID using your app registration's client ID and client secret.
2.  **Use the Microsoft Graph SDK**: To make calls to the Graph API.

A simplified sync process would look like this (in C# pseudocode):

```csharp
// 1. Get an access token using MSAL
var accessToken = await GetAppOnlyGraphAccessToken();
var graphClient = new GraphServiceClient(new DelegateAuthenticationProvider( (requestMessage) => {
    requestMessage.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
    return Task.CompletedTask;
}));

// 2. Sync Users
var entraUsers = await graphClient.Users.Request().GetAsync();
foreach (var user in entraUsers) {
    // Check if user exists in your dbo.Users table using user.Id (EntraObjectID)
    // If not, INSERT.
    // If exists, UPDATE the DisplayName and Email just in case they changed.
}

// 3. Sync Groups
var entraGroups = await graphClient.Groups.Request().GetAsync();
foreach (var group in entraGroups) {
    // Similarly, UPSERT into your dbo.AssignmentGroups table.
    
    // 4. Sync Members for each group
    var members = await graphClient.Groups[group.Id].Members.Request().GetAsync();
    foreach (var member in members) {
        // Find the local UserID and AssignmentGroupID
        // And UPSERT into the dbo.UserGroupMemberships table.
    }
}
```

This synchronization logic can be placed in a background service (like an Azure Function on a timer) or an admin-only page in your web app. Now your application's UI can simply query these local tables to populate your assignment dropdowns.
