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
