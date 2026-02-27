<#
.SYNOPSIS
    Connects to an Azure SQL Database and creates the core ticketing tables.
.DESCRIPTION
    This script creates the lookup tables (TicketStatuses, TicketTypes, Priorities)
    and the main Tickets table with all necessary columns and foreign key relationships.
    It then populates the lookup tables with default values.
#>

# --- Configuration ---
$sqlServerName = "your-sql-server-name.database.windows.net" # <-- UPDATE THIS
$databaseName = "your-database-name"                         # <-- UPDATE THIS
$sqlAdminUser = "your-sql-admin-username"                    # <-- UPDATE THIS


# --- Securely Get Credentials ---
Write-Host "Please enter the password for the SQL user '$sqlAdminUser':"
$password = Read-Host -AsSecureString


# --- Define the T-SQL Query ---
# This multi-line string contains all the SQL commands to be executed.
$createQuery = @"
-- =============================================
-- 1. Create Lookup Tables
-- =============================================

-- Table for Ticket Statuses (e.g., New, In Progress, Closed)
CREATE TABLE dbo.TicketStatuses (
    TicketStatusID INT IDENTITY(1,1) NOT NULL,
    StatusName NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_TicketStatuses PRIMARY KEY CLUSTERED (TicketStatusID ASC)
);

-- Table for Ticket Types (e.g., Incident, Service Request)
CREATE TABLE dbo.TicketTypes (
    TicketTypeID INT IDENTITY(1,1) NOT NULL,
    TypeName NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_TicketTypes PRIMARY KEY CLUSTERED (TicketTypeID ASC)
);

-- Table for Ticket Priorities (e.g., Low, Medium, High)
CREATE TABLE dbo.Priorities (
    PriorityID INT IDENTITY(1,1) NOT NULL,
    PriorityName NVARCHAR(50) NOT NULL,
    SortOrder INT NOT NULL, -- To help order priorities correctly in a UI
    CONSTRAINT PK_Priorities PRIMARY KEY CLUSTERED (PriorityID ASC)
);


-- =============================================
-- 2. Create the Main Tickets Table
-- =============================================
CREATE TABLE dbo.Tickets (
    -- Core Fields
    TicketID INT IDENTITY(1,1) NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,

    -- Foreign Keys to Core Tables
    CustomerID INT NOT NULL,
    ContactID INT NOT NULL,
    SiteID INT NULL,

    -- Foreign Keys to Lookup Tables
    TicketStatusID INT NOT NULL,
    TicketTypeID INT NOT NULL,
    PriorityID INT NOT NULL,

    -- Assignment & SLA
    AssignedToUserID INT NULL, -- For future use when you have technician/user logins
    SlaDueDate DATETIME2(7) NULL,

    -- Metadata
    CreatedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    LastModifiedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    ClosedDate DATETIME2(7) NULL,

    -- Constraints
    CONSTRAINT PK_Tickets PRIMARY KEY CLUSTERED (TicketID ASC),
    CONSTRAINT FK_Tickets_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT FK_Tickets_Contacts FOREIGN KEY (ContactID) REFERENCES dbo.Contacts(ContactID),
    CONSTRAINT FK_Tickets_Sites FOREIGN KEY (SiteID) REFERENCES dbo.Sites(SiteID),
    CONSTRAINT FK_Tickets_TicketStatuses FOREIGN KEY (TicketStatusID) REFERENCES dbo.TicketStatuses(TicketStatusID),
    CONSTRAINT FK_Tickets_TicketTypes FOREIGN KEY (TicketTypeID) REFERENCES dbo.TicketTypes(TicketTypeID),
    CONSTRAINT FK_Tickets_Priorities FOREIGN KEY (PriorityID) REFERENCES dbo.Priorities(PriorityID)
    -- Add FK for AssignedToUserID when you create the Users/Technicians table
);

-- Add indexes for performance on frequently queried columns
CREATE NONCLUSTERED INDEX IX_Tickets_CustomerID ON dbo.Tickets(CustomerID);
CREATE NONCLUSTERED INDEX IX_Tickets_ContactID ON dbo.Tickets(ContactID);
CREATE NONCLUSTERED INDEX IX_Tickets_StatusID ON dbo.Tickets(TicketStatusID);


-- =============================================
-- 3. Populate Lookup Tables with Default Data
-- =============================================
INSERT INTO dbo.TicketStatuses (StatusName) VALUES ('New'), ('In Progress'), ('On Hold'), ('Resolved'), ('Closed');
INSERT INTO dbo.TicketTypes (TypeName) VALUES ('Service Request'), ('Incident'), ('Problem'), ('Question');
INSERT INTO dbo.Priorities (PriorityName, SortOrder) VALUES ('Low', 4), ('Medium', 3), ('High', 2), ('Critical', 1);

"@

# --- Execute the Query ---
try {
    Write-Host "Connecting to database '$databaseName' on server '$sqlServerName'..."

    # The -SuppressProviderContextWarning flag is useful to prevent noise in the output
    Invoke-Sqlcmd -ServerInstance $sqlServerName `
        -Database $databaseName `
        -Username $sqlAdminUser `
        -Password $password `
        -Query $createQuery `
        -QueryTimeout 30 `
        -SuppressProviderContextWarning

    Write-Host -ForegroundColor Green "Successfully created Tickets table and supporting tables!"

} catch {
    Write-Host -ForegroundColor Red "An error occurred during script execution."
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}
