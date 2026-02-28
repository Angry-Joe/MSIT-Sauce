# This script was generated with assistance from Google's Gemini Enterprise on Feb 27, 2026.

<#
.SYNOPSIS
    Creates a comprehensive ServiceRequests table and its entire supporting ecosystem,
    replacing the old Tickets table.

    Response complete
    Gemini replied
    Excellent. This is the heart of your ITSM application. This script will create a robust ServiceRequests table designed for comprehensive data capture and metrics, along with all the necessary new lookup tables.

    To ensure a clean slate, this script will also drop the old Tickets table.

    Key Design Features in This Script:
    Dedicated Notes Table: A ServiceRequestNotes table is created to store an unlimited history of work notes for each request, providing a full audit trail.

    New Lookup Tables: New tables are created for Channels, Impact, Urgency, Request States, On-Hold Reasons, and Resolution Codes to keep data consistent.

    Metrics-Focused Fields: Columns like FirstResponseDate, ReassignmentCount, and CommunicationCount are included to make reporting on KPIs straightforward.

    Sample Data: All new lookup tables are populated with common-sense data to get you started immediately.
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
-- 0. Drop the old Tickets table if it exists
-- =============================================
IF OBJECT_ID('dbo.Tickets', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Tickets;
    PRINT 'Old table dbo.Tickets has been dropped.';
END
GO


-- =============================================
-- 1. Create New Lookup Tables
-- =============================================
CREATE TABLE dbo.Channels (
    ChannelID INT IDENTITY(1,1) PRIMARY KEY,
    ChannelName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dbo.Impacts (
    ImpactID INT IDENTITY(1,1) PRIMARY KEY,
    ImpactName NVARCHAR(50) NOT NULL,
    ImpactLevel INT NOT NULL UNIQUE
);

CREATE TABLE dbo.Urgencies (
    UrgencyID INT IDENTITY(1,1) PRIMARY KEY,
    UrgencyName NVARCHAR(50) NOT NULL,
    UrgencyLevel INT NOT NULL UNIQUE
);

CREATE TABLE dbo.RequestStates (
    RequestStateID INT IDENTITY(1,1) PRIMARY KEY,
    StateName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dbo.OnHoldReasons (
    OnHoldReasonID INT IDENTITY(1,1) PRIMARY KEY,
    ReasonName NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.ResolutionCodes (
    ResolutionCodeID INT IDENTITY(1,1) PRIMARY KEY,
    CodeName NVARCHAR(100) NOT NULL UNIQUE
);
PRINT 'New lookup tables created.';
GO


-- =============================================
-- 2. Create the Core ServiceRequests Table
-- =============================================
CREATE TABLE dbo.ServiceRequests (
    ServiceRequestID INT IDENTITY(1,1) PRIMARY KEY,

    -- Core Information
    Title NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    RequestorContactID INT NOT NULL FOREIGN KEY REFERENCES dbo.Contacts(ContactID),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES dbo.Customers(CustomerID),
    SiteID INT NULL FOREIGN KEY REFERENCES dbo.Sites(SiteID),

    -- Classification
    BusinessServiceID INT NOT NULL FOREIGN KEY REFERENCES dbo.BusinessServices(BusinessServiceID),
    ServiceCategoryID INT NOT NULL FOREIGN KEY REFERENCES dbo.ServiceCategories(ServiceCategoryID),
    ServiceSubcategoryID INT NOT NULL FOREIGN KEY REFERENCES dbo.ServiceSubcategories(ServiceSubcategoryID),
    ChannelID INT NOT NULL FOREIGN KEY REFERENCES dbo.Channels(ChannelID),
    ImpactID INT NOT NULL FOREIGN KEY REFERENCES dbo.Impacts(ImpactID),
    UrgencyID INT NOT NULL FOREIGN KEY REFERENCES dbo.Urgencies(UrgencyID),
    PriorityID INT NOT NULL FOREIGN KEY REFERENCES dbo.Priorities(PriorityID),

    -- State Management
    RequestStateID INT NOT NULL FOREIGN KEY REFERENCES dbo.RequestStates(RequestStateID),
    OnHoldReasonID INT NULL FOREIGN KEY REFERENCES dbo.OnHoldReasons(OnHoldReasonID),

    -- Labor & Assignment
    RequiresTouchLabor BIT NOT NULL DEFAULT 0,
    AssignmentGroupID INT NULL FOREIGN KEY REFERENCES dbo.AssignmentGroups(AssignmentGroupID),
    AssignedToEmployeeID INT NULL FOREIGN KEY REFERENCES dbo.Employees(EmployeeID),

    -- Resolution
    ResolutionNotes NVARCHAR(MAX) NULL,
    ResolutionCodeID INT NULL FOREIGN KEY REFERENCES dbo.ResolutionCodes(ResolutionCodeID),
    ResolvedByEmployeeID INT NULL FOREIGN KEY REFERENCES dbo.Employees(EmployeeID),

    -- Metrics & Metadata
    CreatedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    LastModifiedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    ResolvedDate DATETIME2(7) NULL,
    FirstResponseDate DATETIME2(7) NULL,
    SlaDueDate DATETIME2(7) NULL,
    ReassignmentCount INT NOT NULL DEFAULT 0,
    CommunicationCount INT NOT NULL DEFAULT 0
);
PRINT 'ServiceRequests table created.';
GO


-- =============================================
-- 3. Create the ServiceRequestNotes Table for Audit Trail
-- =============================================
CREATE TABLE dbo.ServiceRequestNotes (
    NoteID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceRequestID INT NOT NULL FOREIGN KEY REFERENCES dbo.ServiceRequests(ServiceRequestID) ON DELETE CASCADE,
    NoteText NVARCHAR(MAX) NOT NULL,
    CreatedByEmployeeID INT NOT NULL FOREIGN KEY REFERENCES dbo.Employees(EmployeeID),
    CreatedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    IsVisibleToCustomer BIT NOT NULL DEFAULT 0 -- Flag to show/hide notes in a self-service portal
);
PRINT 'ServiceRequestNotes table created.';
GO


-- =============================================
-- 4. Populate All New Lookup Tables with Sample Data
-- =============================================
INSERT INTO dbo.Channels (ChannelName) VALUES ('Phone'), ('Email'), ('Self-Service'), ('Direct'), ('Walk-in');
INSERT INTO dbo.Impacts (ImpactName, ImpactLevel) VALUES ('Extensive/Widespread', 1), ('Significant/Large', 2), ('Moderate/Limited', 3), ('Minor/Localized', 4);
INSERT INTO dbo.Urgencies (UrgencyName, UrgencyLevel) VALUES ('Critical', 1), ('High', 2), ('Medium', 3), ('Low', 4);
INSERT INTO dbo.RequestStates (StateName) VALUES ('New'), ('Open'), ('On Hold'), ('Resolved'), ('Canceled'), ('Closed');
INSERT INTO dbo.OnHoldReasons (ReasonName) VALUES ('Awaiting Customer Response'), ('Awaiting Vendor Support'), ('Awaiting Evidence'), ('Awaiting Change Approval');
INSERT INTO dbo.ResolutionCodes (CodeName) VALUES ('Solution Provided'), ('Workaround Provided'), ('No Resolution Provided - Canceled'), ('Duplicate Request');
PRINT 'All lookup tables have been populated.';
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

    Write-Host -ForegroundColor Green "Successfully created the full ServiceRequests ecosystem!"

} catch {
    Write-Host -ForegroundColor Red "An error occurred during script execution."
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}
