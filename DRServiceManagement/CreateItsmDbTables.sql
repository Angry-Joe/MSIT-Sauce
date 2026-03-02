/*
================================================================================
Script:         Create ITSM Service Request Schema
Description:    This script creates the core ServiceRequests table, its
                supporting lookup tables, and a notes table for a new
                ITSM application.

Author:         Joe Leary
                (Scaffolded with assistance from Google's Gemini Enterprise)
Creation Date:  2026-02-27
AI Model Used:  Gemini Enterprise
================================================================================
*/

-- This script creates Customers, Sites, and Contacts tables

-- =============================================
-- Customers Table
-- Stores information about each client company.
-- =============================================

CREATE TABLE dbo.Customers
(
    -- Core Fields
    CustomerID INT IDENTITY(1,1) NOT NULL,
    CompanyName NVARCHAR(255) NOT NULL,

    -- Main Address / Contact Information
    PhoneNumber NVARCHAR(50) NULL,
    Address1 NVARCHAR(255) NULL,
    Address2 NVARCHAR(255) NULL,
    City NVARCHAR(100) NULL,
    StateOrProvince NVARCHAR(100) NULL,
    PostalCode NVARCHAR(20) NULL,
    Country NVARCHAR(100) NULL,

    -- Metadata
    CreatedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    IsActive BIT NOT NULL DEFAULT 1,

    -- Constraints
    CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (CustomerID ASC)
);

-- Add an index on CompanyName for faster lookups
CREATE NONCLUSTERED INDEX IX_Customers_CompanyName ON dbo.Customers(CompanyName);

-- =============================================
-- Sites Table
-- Stores physical locations for each customer.
-- =============================================
CREATE TABLE dbo.Sites
(
    -- Core Fields
    SiteID INT IDENTITY(1,1) NOT NULL,
    CustomerID INT NOT NULL,
    -- Foreign Key to Customers table
    SiteName NVARCHAR(255) NOT NULL,

    -- Site-specific Address / Contact Information
    Address1 NVARCHAR(255) NULL,
    Address2 NVARCHAR(255) NULL,
    City NVARCHAR(100) NULL,
    StateOrProvince NVARCHAR(100) NULL,
    PostalCode NVARCHAR(20) NULL,
    Country NVARCHAR(100) NULL,
    SitePhoneNumber NVARCHAR(50) NULL,

    -- Metadata
    CreatedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    IsActive BIT NOT NULL DEFAULT 1,

    -- Constraints
    CONSTRAINT PK_Sites PRIMARY KEY CLUSTERED (SiteID ASC),
    CONSTRAINT FK_Sites_Customers FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID)
        ON DELETE CASCADE
    -- If a customer is deleted, all their sites are deleted too.
);

-- Add an index on CustomerID for faster lookups of all sites for a customer
CREATE NONCLUSTERED INDEX IX_Sites_CustomerID ON dbo.Sites(CustomerID);

-- =============================================
-- Contacts Table
-- Stores individual contacts for each customer/site.
-- =============================================
CREATE TABLE dbo.Contacts
(
    -- Core Fields
    ContactID INT IDENTITY(1,1) NOT NULL,
    CustomerID INT NOT NULL,
    -- Foreign Key to Customers
    SiteID INT NULL,
    -- Foreign Key to Sites (NULLable if contact is not site-specific)

    -- Contact Details
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    EmailAddress NVARCHAR(255) NOT NULL,
    -- Crucial for login and notifications
    JobTitle NVARCHAR(100) NULL,
    PhoneNumber NVARCHAR(50) NULL,

    -- Roles and Permissions
    IsPrimaryContactForCustomer BIT NOT NULL DEFAULT 0,
    IsPrimaryContactForSite BIT NOT NULL DEFAULT 0,
    -- CanLogin BIT NOT NULL DEFAULT 1, -- Future use: To enable/disable a user's login access

    -- Metadata
    CreatedDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    IsActive BIT NOT NULL DEFAULT 1,

    -- Constraints
    CONSTRAINT PK_Contacts PRIMARY KEY CLUSTERED (ContactID ASC),
    CONSTRAINT UQ_Contacts_EmailAddress UNIQUE (EmailAddress),
    -- Ensures every email is unique
    CONSTRAINT FK_Contacts_Customers FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),
    -- Can't delete a customer if they still have contacts
    CONSTRAINT FK_Contacts_Sites FOREIGN KEY (SiteID)
        REFERENCES dbo.Sites(SiteID)
    -- Can't delete a site if it's assigned to a contact
);

-- Add indexes for faster lookups on foreign keys and email
CREATE NONCLUSTERED INDEX IX_Contacts_CustomerID ON dbo.Contacts(CustomerID);
CREATE NONCLUSTERED INDEX IX_Contacts_SiteID ON dbo.Contacts(SiteID);

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
GO

-- =============================================
-- 4. Create Service Catalog Tables
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
GO
-- Service Categories: A classification within a Business Service (e.g., Hardware Support)
CREATE TABLE dbo.ServiceCategories (
    ServiceCategoryID INT IDENTITY(1,1) NOT NULL,
    BusinessServiceID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_ServiceCategories PRIMARY KEY CLUSTERED (ServiceCategoryID ASC),
    CONSTRAINT FK_ServiceCategories_BusinessServices FOREIGN KEY (BusinessServiceID) REFERENCES dbo.BusinessServices(BusinessServiceID) ON DELETE CASCADE
);
GO
-- Service Subcategories: A specific type of request within a category (e.g., New Laptop Request)
CREATE TABLE dbo.ServiceSubcategories (
    ServiceSubcategoryID INT IDENTITY(1,1) NOT NULL,
    ServiceCategoryID INT NOT NULL,
    SubcategoryName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_ServiceSubcategories PRIMARY KEY CLUSTERED (ServiceSubcategoryID ASC),
    CONSTRAINT FK_ServiceSubcategories_ServiceCategories FOREIGN KEY (ServiceCategoryID) REFERENCES dbo.ServiceCategories(ServiceCategoryID) ON DELETE CASCADE
);
GO
-- =============================================
-- 5. Populate Tables with Sample Data
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

---- =============================================
---- 0. Drop the old Tickets table if it exists
---- =============================================
--IF OBJECT_ID('dbo.Tickets', 'U') IS NOT NULL
--BEGIN
--    DROP TABLE dbo.Tickets;
--    PRINT 'Old table dbo.Tickets has been dropped.';
--END
--GO

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

CREATE TABLE dbo.Priorities (
    PriorityID INT IDENTITY(1,1) PRIMARY KEY,
    PriorityName NVARCHAR(50) NOT NULL UNIQUE,
    PriorityLevel INT NOT NULL UNIQUE
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
INSERT INTO dbo.Priorities (PriorityName, PriorityLevel) VALUES ('Critical', 1), ('High', 2), ('Medium', 3), ('Low', 4);
PRINT 'All lookup tables have been populated.';
GO