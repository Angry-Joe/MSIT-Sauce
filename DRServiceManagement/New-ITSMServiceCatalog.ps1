# This script was generated with assistance from Google's Gemini Enterprise on Feb 27, 2026.

<#
.SYNOPSIS
    Creates the three-tiered service catalog tables (BusinessServices, 
    ServiceCategories, ServiceSubcategories), updates the Tickets table,
    and populates them with common ITSM sample data.

    PowerShell Script to Create Service Catalog Tables and Sample Data
    This script assumes the AssignmentGroups table from our previous step exists. It will add a few sample groups ('Help Desk', 'Network Team', 'SysAdmin Team') to make the sample data realistic.

    ### How to Use This in Your App
    With this structure in place, the workflow for creating a new ticket in your web app will be:

    User selects a Business Service from a dropdown.

    Based on that selection, the Service Category dropdown is populated.

    Based on the category selection, the Service Subcategory dropdown is populated.

    When the ticket is submitted, the DefaultAssignmentGroupID from the chosen BusinessService can be automatically set as the AssignmentGroupID on the ticket, routing it to the correct team instantly.
#>

# --- Configuration ---
$sqlServerName = "your-sql-server-name.database.windows.net" # <-- UPDATE THIS
$databaseName = "your-database-name"                         # <-- UPDATE THIS
$sqlAdminUser = "your-sql-admin-username"                    # <-- UPDATE THIS


# --- Securely Get Credentials ---
Write-Host "Please enter the password for the SQL user '$sqlAdminUser':"
$password = Read-Host -AsSecureString


# --- Define the T-SQL Query ---
$createQuery = @"
-- =============================================
-- 1. Create Service Catalog Tables
-- =============================================

-- Business Services: The highest level of classification (e.g., End User Devices)
CREATE TABLE dbo.BusinessServices (
    BusinessServiceID INT IDENTITY(1,1) NOT NULL,
    ServiceName NVARCHAR(100) NOT NULL,
    DefaultAssignmentGroupID INT NULL, -- The group that typically handles this service

    CONSTRAINT PK_BusinessServices PRIMARY KEY CLUSTERED (BusinessServiceID ASC),
    CONSTRAINT UQ_BusinessServices_ServiceName UNIQUE (ServiceName),
    CONSTRAINT FK_BusinessServices_DefaultAssignmentGroup FOREIGN KEY (DefaultAssignmentGroupID) REFERENCES dbo.AssignmentGroups(AssignmentGroupID)
);

-- Service Categories: A classification within a Business Service (e.g., Hardware Support)
CREATE TABLE dbo.ServiceCategories (
    ServiceCategoryID INT IDENTITY(1,1) NOT NULL,
    BusinessServiceID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_ServiceCategories PRIMARY KEY CLUSTERED (ServiceCategoryID ASC),
    CONSTRAINT FK_ServiceCategories_BusinessServices FOREIGN KEY (BusinessServiceID) REFERENCES dbo.BusinessServices(BusinessServiceID) ON DELETE CASCADE
);

-- Service Subcategories: A specific type of request within a category (e.g., New Laptop Request)
CREATE TABLE dbo.ServiceSubcategories (
    ServiceSubcategoryID INT IDENTITY(1,1) NOT NULL,
    ServiceCategoryID INT NOT NULL,
    SubcategoryName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_ServiceSubcategories PRIMARY KEY CLUSTERED (ServiceSubcategoryID ASC),
    CONSTRAINT FK_ServiceSubcategories_ServiceCategories FOREIGN KEY (ServiceCategoryID) REFERENCES dbo.ServiceCategories(ServiceCategoryID) ON DELETE CASCADE
);


-- =============================================
-- 2. Alter the Tickets Table to use the Service Catalog
-- =============================================
ALTER TABLE dbo.Tickets
ADD BusinessServiceID INT NULL,
    ServiceCategoryID INT NULL,
    ServiceSubcategoryID INT NULL;

ALTER TABLE dbo.Tickets
ADD CONSTRAINT FK_Tickets_BusinessService FOREIGN KEY (BusinessServiceID) REFERENCES dbo.BusinessServices(BusinessServiceID);

ALTER TABLE dbo.Tickets
ADD CONSTRAINT FK_Tickets_ServiceCategory FOREIGN KEY (ServiceCategoryID) REFERENCES dbo.ServiceCategories(ServiceCategoryID);

ALTER TABLE dbo.Tickets
ADD CONSTRAINT FK_Tickets_ServiceSubcategory FOREIGN KEY (ServiceSubcategoryID) REFERENCES dbo.ServiceSubcategories(ServiceSubcategoryID);

GO -- End of schema changes batch


-- =============================================
-- 3. Populate Tables with Sample Data
-- =============================================
-- First, ensure some assignment groups exist to reference them.
-- We use MERGE to avoid errors if you run the script more than once.
MERGE dbo.AssignmentGroups AS Target
USING (VALUES ('Help Desk'), ('Network Team'), ('SysAdmin Team')) AS Source (GroupName)
ON Target.GroupName = Source.GroupName
WHEN NOT MATCHED BY TARGET THEN
    INSERT (GroupName) VALUES (Source.GroupName);

-- Declare variables to hold the IDs of our new groups for easier reference
DECLARE @HelpDeskID INT = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'Help Desk');
DECLARE @NetworkTeamID INT = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'Network Team');
DECLARE @SysAdminTeamID INT = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'SysAdmin Team');

-- Now, populate the service catalog, linking services to default groups
-- Business Service: End User Devices
INSERT INTO dbo.BusinessServices (ServiceName, DefaultAssignmentGroupID) VALUES ('End User Devices', @HelpDeskID);
DECLARE @EUD_ServiceID INT = SCOPE_IDENTITY();
    INSERT INTO dbo.ServiceCategories (BusinessServiceID, CategoryName) VALUES (@EUD_ServiceID, 'Hardware Support');
    DECLARE @EUD_Hardware_CatID INT = SCOPE_IDENTITY();
        INSERT INTO dbo.ServiceSubcategories (ServiceCategoryID, SubcategoryName) VALUES (@EUD_Hardware_CatID, 'New Laptop Request'), (@EUD_Hardware_CatID, 'Monitor Issue'), (@EUD_Hardware_CatID, 'Docking Station Problem');
    INSERT INTO dbo.ServiceCategories (BusinessServiceID, CategoryName) VALUES (@EUD_ServiceID, 'Software Support');
    DECLARE @EUD_Software_CatID INT = SCOPE_IDENTITY();
        INSERT INTO dbo.ServiceSubcategories (ServiceCategoryID, SubcategoryName) VALUES (@EUD_Software_CatID, 'Software Installation Request'), (@EUD_Software_CatID, 'Application Error / Crash'), (@EUD_Software_CatID, 'License Renewal');

-- Business Service: Network & Connectivity
INSERT INTO dbo.BusinessServices (ServiceName, DefaultAssignmentGroupID) VALUES ('Network & Connectivity', @NetworkTeamID);
DECLARE @Network_ServiceID INT = SCOPE_IDENTITY();
    INSERT INTO dbo.ServiceCategories (BusinessServiceID, CategoryName) VALUES (@Network_ServiceID, 'Internet Access');
    DECLARE @Network_Internet_CatID INT = SCOPE_IDENTITY();
        INSERT INTO dbo.ServiceSubcategories (ServiceCategoryID, SubcategoryName) VALUES (@Network_Internet_CatID, 'No Internet Connectivity'), (@Network_Internet_CatID, 'Slow Internet Performance');
    INSERT INTO dbo.ServiceCategories (BusinessServiceID, CategoryName) VALUES (@Network_ServiceID, 'VPN Access');
    DECLARE @Network_VPN_CatID INT = SCOPE_IDENTITY();
        INSERT INTO dbo.ServiceSubcategories (ServiceCategoryID, SubcategoryName) VALUES (@Network_VPN_CatID, 'VPN Access Request'), (@Network_VPN_CatID, 'VPN Connection Dropping');

-- Business Service: Accounts & Access
INSERT INTO dbo.BusinessServices (ServiceName, DefaultAssignmentGroupID) VALUES ('Accounts & Access', @SysAdminTeamID);
DECLARE @Accounts_ServiceID INT = SCOPE_IDENTITY();
    INSERT INTO dbo.ServiceCategories (BusinessServiceID, CategoryName) VALUES (@Accounts_ServiceID, 'User Account Management');
    DECLARE @Accounts_User_CatID INT = SCOPE_IDENTITY();
        INSERT INTO dbo.ServiceSubcategories (ServiceCategoryID, SubcategoryName) VALUES (@Accounts_User_CatID, 'New User Account'), (@Accounts_User_CatID, 'Password Reset'), (@Accounts_User_CatID, 'Account Lockout');
    INSERT INTO dbo.ServiceCategories (BusinessServiceID, CategoryName) VALUES (@Accounts_ServiceID, 'Shared Resource Access');
    DECLARE @Accounts_Resource_CatID INT = SCOPE_IDENTITY();
        INSERT INTO dbo.ServiceSubcategories (ServiceCategoryID, SubcategoryName) VALUES (@Accounts_Resource_CatID, 'Shared Mailbox Access'), (@Accounts_Resource_CatID, 'File Share Access Request');
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

    Write-Host -ForegroundColor Green "Successfully created and populated Service Catalog tables!"

} catch {
    Write-Host -ForegroundColor Red "An error occurred during script execution."
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}
