# This script was generated with assistance from Google's Gemini Enterprise on Feb 27, 2026.

<#
.SYNOPSIS
    Creates local, organic tables for employees and assignment groups,
    structured for future Entra ID integration.

    The key is including nullable EntraObjectID and EntraGroupID columns. For now, they will be empty, but when you're ready to integrate, your synchronization script will simply populate these fields, linking your organic records to the live Entra objects.

    Here is the PowerShell script to create the Employees, AssignmentGroups, and membership tables, and to update the Tickets table accordingly.

    PowerShell Script to Create Organic Employee and Group Tables
    This script will:

    Create an Employees table with fields that mirror Entra ID user attributes.
    Create an AssignmentGroups table for your teams.
    Create a EmployeeGroupMemberships table to link them.
    Alter the Tickets table to use these new tables for assignments.

    How This Gets Your App Off the Ground
    Immediate Use: You can now build admin pages in your web app to manually add, edit, and disable records in the Employees and AssignmentGroups tables.

    Populate Dropdowns: The "Assigned To" dropdown in your new ticket form will be populated from dbo.Employees where IsActive = 1. The "Assignment Group" dropdown will be populated from dbo.AssignmentGroups.

    Ready for the Future: When you are ready to integrate with Entra ID, you won't need to change your schema. Your sync process will:

    Read users/groups from Microsoft Graph.

    Check if a user/group with that EntraObjectID already exists in your tables.

    If yes, update their details (like name).

    If no, INSERT a new record, storing their EntraObjectID.

    This is a robust and flexible strategy that perfectly balances immediate needs with long-term goals.
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
-- 1. Create Employees Table
-- =============================================
CREATE TABLE dbo.Employees (
    EmployeeID INT IDENTITY(1,1) NOT NULL,
    EntraObjectID UNIQUEIDENTIFIER NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DisplayName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    JobTitle NVARCHAR(100) NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_Employees PRIMARY KEY CLUSTERED (EmployeeID ASC),
    CONSTRAINT UQ_Employees_Email UNIQUE (Email)
    -- The filtered unique constraint has been moved outside the table definition.
);
GO

-- Create the filtered unique index for EntraObjectID (Correct Method)
CREATE UNIQUE NONCLUSTERED INDEX UQ_Employees_EntraObjectID
ON dbo.Employees(EntraObjectID)
WHERE EntraObjectID IS NOT NULL;
GO

-- Create the other non-clustered index
CREATE NONCLUSTERED INDEX IX_Employees_DisplayName ON dbo.Employees(DisplayName);
GO


-- =============================================
-- 2. Create Assignment Groups Table
-- =============================================
CREATE TABLE dbo.AssignmentGroups (
    AssignmentGroupID INT IDENTITY(1,1) NOT NULL,
    EntraGroupID UNIQUEIDENTIFIER NULL,
    GroupName NVARCHAR(255) NOT NULL,
    GroupEmail NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_AssignmentGroups PRIMARY KEY CLUSTERED (AssignmentGroupID ASC),
    CONSTRAINT UQ_AssignmentGroups_GroupName UNIQUE (GroupName)
    -- The filtered unique constraint has been moved outside the table definition.
);
GO

-- Create the filtered unique index for EntraGroupID (Correct Method)
CREATE UNIQUE NONCLUSTERED INDEX UQ_AssignmentGroups_EntraGroupID
ON dbo.AssignmentGroups(EntraGroupID)
WHERE EntraGroupID IS NOT NULL;
GO


-- =============================================
-- 3. Create Employee-Group Membership Table (Many-to-Many)
-- =============================================
CREATE TABLE dbo.EmployeeGroupMemberships (
    EmployeeID INT NOT NULL,
    AssignmentGroupID INT NOT NULL,

    CONSTRAINT PK_EmployeeGroupMemberships PRIMARY KEY CLUSTERED (EmployeeID, AssignmentGroupID),
    CONSTRAINT FK_EmployeeGroupMemberships_Employees FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID) ON DELETE CASCADE,
    CONSTRAINT FK_EmployeeGroupMemberships_AssignmentGroups FOREIGN KEY (AssignmentGroupID) REFERENCES dbo.AssignmentGroups(AssignmentGroupID) ON DELETE CASCADE
);

-- =============================================
-- 4. Alter the Tickets Table for Assignments
-- This adds the foreign key columns for assigning tickets.
-- NOTE: This assumes the columns from the previous script do not exist.
-- If they do, you may need to drop them first.
-- =============================================
ALTER TABLE dbo.Tickets
ADD AssignedToEmployeeID INT NULL;

ALTER TABLE dbo.Tickets
ADD AssignmentGroupID INT NULL;

-- Now, add the relationships
ALTER TABLE dbo.Tickets
ADD CONSTRAINT FK_Tickets_AssignedToEmployee FOREIGN KEY (AssignedToEmployeeID) REFERENCES dbo.Employees(EmployeeID);

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

    Write-Host -ForegroundColor Green "Successfully created organic Employee and Group tables!"

} catch {
    Write-Host -ForegroundColor Red "An error occurred during script execution."
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}

# Add sample data
# --- Define the T-SQL Query ---
$createQuery = @"
-- =============================================
-- 1. Add Sample Assignment Groups
-- MERGE prevents creating duplicates if the script is run again.
-- =============================================
PRINT 'Merging sample data into AssignmentGroups...';
MERGE dbo.AssignmentGroups AS Target
USING (VALUES 
    ('Help Desk', 'helpdesk@example.com'), 
    ('Network Team', 'network@example.com'), 
    ('SysAdmin Team', 'sysadmin@example.com')
) AS Source (GroupName, GroupEmail)
ON Target.GroupName = Source.GroupName
WHEN NOT MATCHED BY TARGET THEN
    INSERT (GroupName, GroupEmail) VALUES (Source.GroupName, Source.GroupEmail);
GO

-- =============================================
-- 2. Add Sample Employees
-- MERGE prevents creating duplicate employees based on their email address.
-- =============================================
PRINT 'Merging sample data into Employees...';
MERGE dbo.Employees AS Target
USING (VALUES
    ('Alice', 'Wonder', 'Alice Wonder', 'alice@example.com', 'IT Support Specialist'),
    ('Bob', 'Builder', 'Bob Builder', 'bob@example.com', 'Senior Network Engineer'),
    ('Charlie', 'Chocolate', 'Charlie Chocolate', 'charlie@example.com', 'System Administrator'),
    ('Diana', 'Prince', 'Diana Prince', 'diana@example.com', 'IT Manager')
) AS Source (FirstName, LastName, DisplayName, Email, JobTitle)
ON Target.Email = Source.Email
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FirstName, LastName, DisplayName, Email, JobTitle) 
    VALUES (Source.FirstName, Source.LastName, Source.DisplayName, Source.Email, Source.JobTitle);
GO

-- =============================================
-- 3. Link Employees to Groups (Create Memberships)
-- =============================================
PRINT 'Merging employee group memberships...';

-- First, get the IDs of the records we just created/verified.
DECLARE @HelpDeskID INT = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'Help Desk');
DECLARE @NetworkTeamID INT = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'Network Team');
DECLARE @SysAdminTeamID INT = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'SysAdmin Team');

DECLARE @AliceID INT = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'alice@example.com');
DECLARE @BobID INT = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'bob@example.com');
DECLARE @CharlieID INT = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'charlie@example.com');
DECLARE @DianaID INT = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'diana@example.com');

-- Now, MERGE the relationships into the membership table.
MERGE dbo.EmployeeGroupMemberships AS Target
USING (VALUES
    (@AliceID, @HelpDeskID),        -- Alice is in the Help Desk
    (@BobID, @NetworkTeamID),         -- Bob is on the Network Team
    (@CharlieID, @SysAdminTeamID),    -- Charlie is a SysAdmin
    (@DianaID, @HelpDeskID),          -- Diana (Manager) is in all groups
    (@DianaID, @NetworkTeamID),
    (@DianaID, @SysAdminTeamID)
) AS Source (EmployeeID, AssignmentGroupID)
ON Target.EmployeeID = Source.EmployeeID AND Target.AssignmentGroupID = Source.AssignmentGroupID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (EmployeeID, AssignmentGroupID) VALUES (Source.EmployeeID, Source.AssignmentGroupID);
GO

PRINT 'Sample data population complete.';
GO
"@

# --- Execute the Query ---
try {
    Write-Host "Connecting to database '$databaseName' to add sample data..."
    Invoke-Sqlcmd -ServerInstance $sqlServerName `
        -Database $databaseName `
        -Username $sqlAdminUser `        -Password $password `
        -Query $createQuery `
        -SuppressProviderContextWarning

    Write-Host -ForegroundColor Green "Successfully added/verified sample data for Employees and Groups."

} catch {
    Write-Host -ForegroundColor Red "An error occurred during script execution."
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}
