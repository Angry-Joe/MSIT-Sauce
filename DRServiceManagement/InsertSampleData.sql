-- =============================================
-- LOTR-Themed Sample Data
-- =============================================

-- 1. The Shire Trading Company (Hobbit-themed)
DECLARE @ShireID INT;

INSERT INTO dbo.Customers (CompanyName, PhoneNumber, Address1, City, StateOrProvince, PostalCode, Country)
VALUES ('The Shire Trading Company', '(555) 123-4567', '1 Bagshot Row', 'Hobbiton', 'The Shire', '00001', 'Middle-earth');

SET @ShireID = SCOPE_IDENTITY();

-- Sites for Shire
DECLARE @HobbitonID INT, @BucklandID INT;

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@ShireID, 'Hobbiton Depot', 'Party Field', 'Hobbiton', 'The Shire', '00001', 'Middle-earth', '(555) 123-4568');

SET @HobbitonID = SCOPE_IDENTITY();

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@ShireID, 'Buckland Warehouse', 'Buckland Road', 'Buckland', 'The Shire', '00002', 'Middle-earth', '(555) 123-4569');

SET @BucklandID = SCOPE_IDENTITY();

-- Contacts for Shire (3 total)
INSERT INTO dbo.Contacts (CustomerID, SiteID, FirstName, LastName, EmailAddress, JobTitle, IsPrimaryContactForCustomer, IsPrimaryContactForSite)
VALUES
    (@ShireID, @HobbitonID, 'Frodo', 'Baggins', 'frodo.baggins@shiretrading.com', 'Senior IT Support Specialist', 1, 1),
    (@ShireID, @HobbitonID, 'Samwise', 'Gamgee', 'sam.gamgee@shiretrading.com', 'Field Technician', 0, 1),
    (@ShireID, @BucklandID, 'Meriadoc', 'Brandybuck', 'merry.brandybuck@shiretrading.com', 'Logistics Coordinator', 0, 0);

-- 2. Rivendell Holdings (Elf-themed)
DECLARE @RivendellID INT;

INSERT INTO dbo.Customers (CompanyName, PhoneNumber, Address1, City, StateOrProvince, PostalCode, Country)
VALUES ('Rivendell Holdings', '(555) 987-6543', 'The Last Homely House', 'Rivendell', 'Eregion', '00010', 'Middle-earth');

SET @RivendellID = SCOPE_IDENTITY();

-- Sites for Rivendell
DECLARE @LastHomelyID INT, @BruinenID INT;

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@RivendellID, 'Last Homely House HQ', 'River Bruinen Valley', 'Rivendell', 'Eregion', '00010', 'Middle-earth', '(555) 987-6544');

SET @LastHomelyID = SCOPE_IDENTITY();

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@RivendellID, 'Bruinen Ford Outpost', 'Bruinen Crossing', 'Rivendell', 'Eregion', '00011', 'Middle-earth', '(555) 987-6545');

SET @BruinenID = SCOPE_IDENTITY();

-- Contacts for Rivendell
INSERT INTO dbo.Contacts (CustomerID, SiteID, FirstName, LastName, EmailAddress, JobTitle, IsPrimaryContactForCustomer, IsPrimaryContactForSite)
VALUES
    (@RivendellID, @LastHomelyID, 'Elrond', 'Halfelven', 'elrond@rivendellholdings.com', 'Chief Technology Officer', 1, 1),
    (@RivendellID, @LastHomelyID, 'Arwen', 'Undomiel', 'arwen@rivendellholdings.com', 'Network Security Lead', 0, 1),
    (@RivendellID, @BruinenID, 'Glorfindel', 'of Rivendell', 'glorfindel@rivendellholdings.com', 'Senior Field Engineer', 0, 0);

-- 3. Gondor Imperial Logistics (Man-themed)
DECLARE @GondorID INT;

INSERT INTO dbo.Customers (CompanyName, PhoneNumber, Address1, City, StateOrProvince, PostalCode, Country)
VALUES ('Gondor Imperial Logistics', '(555) 555-1212', 'White Tower', 'Minas Tirith', 'Gondor', '00020', 'Middle-earth');

SET @GondorID = SCOPE_IDENTITY();

-- Sites for Gondor
DECLARE @MinasTirithID INT, @OsgiliathID INT;

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@GondorID, 'Minas Tirith Citadel', '7th Level', 'Minas Tirith', 'Gondor', '00020', 'Middle-earth', '(555) 555-1213');

SET @MinasTirithID = SCOPE_IDENTITY();

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@GondorID, 'Osgiliath Bridge Station', 'Anduin River Crossing', 'Osgiliath', 'Gondor', '00021', 'Middle-earth', '(555) 555-1214');

SET @OsgiliathID = SCOPE_IDENTITY();

-- Contacts for Gondor
INSERT INTO dbo.Contacts (CustomerID, SiteID, FirstName, LastName, EmailAddress, JobTitle, IsPrimaryContactForCustomer, IsPrimaryContactForSite)
VALUES
    (@GondorID, @MinasTirithID, 'Aragorn', 'Elessar', 'aragorn@gondorlogistics.com', 'Operations Director', 1, 1),
    (@GondorID, @MinasTirithID, 'Boromir', 'Son of Denethor', 'boromir@gondorlogistics.com', 'Fleet Manager', 0, 1),
    (@GondorID, @OsgiliathID, 'Faramir', 'Steward', 'faramir@gondorlogistics.com', 'Site Supervisor', 0, 0);

PRINT '✅ LOTR-themed sample data inserted successfully!';
PRINT '   3 Companies, 6 Sites, 9 Contacts added.';
GO

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
    ('Alice', 'Wonder', 'Alice Wonder', 'alice@example.com', 'IT Support Specialist',1),
    ('Bob', 'Builder', 'Bob Builder', 'bob@example.com', 'Senior Network Engineer',1),
    ('Charlie', 'Chocolate', 'Charlie Chocolate', 'charlie@example.com', 'System Administrator',1),
    ('Diana', 'Prince', 'Diana Prince', 'diana@example.com', 'IT Manager',1),
    ('Gandalf', 'the Grey', 'Gandalf the Grey', 'gandalf@istari.it', 'Chief Wizard Architect', 1),
    ('Legolas', 'Greenleaf', 'Legolas Greenleaf', 'legolas@woodland.net', 'Elven Network Ranger', 1),
    ('Gimli', 'son of Glóin', 'Gimli son of Glóin', 'gimli@erebor.hardware', 'Dwarven Infrastructure Engineer', 1),
    ('Galadriel', 'of Lothlórien', 'Galadriel', 'galadriel@lorien.security', 'Lady of Light - Security Director', 1),
    ('Aragorn', 'Elessar', 'Aragorn Elessar', 'aragorn@gondor.ops', 'Ranger Operations Manager', 1),
    ('Pippin', 'Took', 'Peregrin Took', 'pippin@shiretech.com', 'Junior Field Technician', 1),
    ('Éowyn', 'of Rohan', 'Éowyn', 'eowyn@rohan.support', 'Shieldmaiden Support Lead', 1)
) AS Source (FirstName, LastName, DisplayName, Email, JobTitle,IsActive)
ON Target.Email = Source.Email
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FirstName, LastName, DisplayName, Email, JobTitle, IsActive)
    VALUES (Source.FirstName, Source.LastName, Source.DisplayName, Source.Email, Source.JobTitle, Source.IsActive);
GO

-- =============================================
-- 3. Link Employees to Groups (Create Memberships)
-- =============================================
PRINT 'Merging employee group memberships...';

-- First, get the IDs of the records we just created/verified.
DECLARE @HelpDeskID INT     = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'Help Desk');
DECLARE @NetworkTeamID INT  = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'Network Team');
DECLARE @SysAdminTeamID INT = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'SysAdmin Team');
DECLARE @FellowshipID INT   = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Fellowship Help Desk');
DECLARE @RohanID INT        = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Riders of Rohan');
DECLARE @IstariID INT       = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Istari Council');
DECLARE @RangersID INT      = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Rangers of the North');

DECLARE @AliceID INT        = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'alice@example.com');
DECLARE @BobID INT          = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'bob@example.com');
DECLARE @CharlieID INT      = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'charlie@example.com');
DECLARE @DianaID INT        = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'diana@example.com');
DECLARE @GandalfID INT      = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'gandalf@istari.it');
DECLARE @LegolasID INT      = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'legolas@woodland.net');
DECLARE @GimliID INT        = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'gimli@erebor.hardware');
DECLARE @GaladrielID INT    = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'galadriel@lorien.security');
DECLARE @AragornID INT      = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'aragorn@gondor.ops');
DECLARE @PippinID INT       = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'pippin@shiretech.com');
DECLARE @EowynID INT        = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'eowyn@rohan.support');

-- Now, MERGE the relationships into the membership table.
MERGE dbo.EmployeeGroupMemberships AS Target
USING (VALUES
    (@AliceID, @HelpDeskID),        -- Alice is in the Help Desk
    (@BobID, @NetworkTeamID),         -- Bob is on the Network Team
    (@CharlieID, @SysAdminTeamID),    -- Charlie is a SysAdmin
    (@DianaID, @HelpDeskID),          -- Diana (Manager) is in all groups
    (@DianaID, @NetworkTeamID),
    (@DianaID, @SysAdminTeamID),
    (@GandalfID, @IstariID), (@GandalfID, @FellowshipID),
    (@LegolasID, @FellowshipID), (@LegolasID, @RangersID),
    (@GimliID, @FellowshipID), (@GimliID, @RohanID),
    (@GaladrielID, @FellowshipID), (@GaladrielID, @IstariID),
    (@AragornID, @FellowshipID), (@AragornID, @RangersID),
    (@PippinID, @FellowshipID), (@EowynID, @RohanID)
) AS Source (EmployeeID, AssignmentGroupID)
ON Target.EmployeeID = Source.EmployeeID AND Target.AssignmentGroupID = Source.AssignmentGroupID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (EmployeeID, AssignmentGroupID) VALUES (Source.EmployeeID, Source.AssignmentGroupID);
GO

PRINT 'Sample data population complete.';
GO

---- =============================================
---- 4. Populate All New Lookup Tables with Sample Data
---- =============================================
--INSERT INTO dbo.Channels (ChannelName) VALUES ('Phone'), ('Email'), ('Self-Service'), ('Direct'), ('Walk-in');
--INSERT INTO dbo.Impacts (ImpactName, ImpactLevel) VALUES ('Extensive/Widespread', 1), ('Significant/Large', 2), ('Moderate/Limited', 3), ('Minor/Localized', 4);
--INSERT INTO dbo.Urgencies (UrgencyName, UrgencyLevel) VALUES ('Critical', 1), ('High', 2), ('Medium', 3), ('Low', 4);
--INSERT INTO dbo.RequestStates (StateName) VALUES ('New'), ('Open'), ('On Hold'), ('Resolved'), ('Canceled'), ('Closed');
--INSERT INTO dbo.OnHoldReasons (ReasonName) VALUES ('Awaiting Customer Response'), ('Awaiting Vendor Support'), ('Awaiting Evidence'), ('Awaiting Change Approval');
--INSERT INTO dbo.ResolutionCodes (CodeName) VALUES ('Solution Provided'), ('Workaround Provided'), ('No Resolution Provided - Canceled'), ('Duplicate Request');
--INSERT INTO dbo.Priorities (PriorityName, PriorityLevel) VALUES ('Critical', 1), ('High', 2), ('Medium', 3), ('Low', 4);
--PRINT 'All lookup tables have been populated.';
--GO

-- =============================================
-- Lookup Tables with LOTR Easter Eggs (Fixed)
-- =============================================
PRINT 'Populating lookup tables with epic Easter eggs...';

INSERT INTO dbo.Channels (ChannelName)
VALUES ('Palantír Vision'), ('Raven Messenger'), ('Eagle Delivery');

INSERT INTO dbo.Impacts (ImpactName, ImpactLevel)
VALUES ('One Ring Catastrophic', 0),
       ('Mordor Widespread', 1),
       ('Balrog Level', 2);

INSERT INTO dbo.Urgencies (UrgencyName, UrgencyLevel)
VALUES ('Nazgûl Urgent', 0),
       ('Balrog Immediate', 1);

INSERT INTO dbo.RequestStates (StateName)
VALUES ('Questing'), ('Fellowship Formed'), ('The Ring is Destroyed');

INSERT INTO dbo.OnHoldReasons (ReasonName)
VALUES ('Waiting for the Eagles'),
       ('Awaiting Mithril Shipment'),
       ('The Council is Debating');

INSERT INTO dbo.ResolutionCodes (CodeName)
VALUES ('Ring Destroyed'),
       ('Quest Completed'),
       ('The Eagles Saved Us'),
       ('One Does Not Simply Resolve');

INSERT INTO dbo.Priorities (PriorityName, PriorityLevel)
VALUES ('Mithril Priority', 0),
       ('Fellowship Critical', 1);

PRINT '✅ All lookup tables populated with epic Easter eggs!';
GO