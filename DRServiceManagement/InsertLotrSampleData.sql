-- =============================================
-- LOTR-Themed FULL Sample Data (Updated)
-- 3 Companies × 2 Sites × 3 Contacts + Themed Employees + Easter Eggs
-- =============================================

-- Lothlórien Silvan Networks (Elf forest theme)
DECLARE @LothlorienID INT;

INSERT INTO dbo.Customers (CompanyName, PhoneNumber, Address1, City, StateOrProvince, PostalCode, Country)
VALUES ('Lothlórien Silvan Networks', '(555) 777-8888', 'Golden Mallorn Grove', 'Caras Galadhon', 'Lothlórien', '00030', 'Middle-earth');

SET @LothlorienID = SCOPE_IDENTITY();

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@LothlorienID, 'Caras Galadhon HQ', 'Mallorn Tree Plaza', 'Caras Galadhon', 'Lothlórien', '00030', 'Middle-earth', '(555) 777-8889');

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@LothlorienID, 'Certhas Galadhon Outpost', 'Northern Forest Edge', 'Certhas Galadhon', 'Lothlórien', '00031', 'Middle-earth', '(555) 777-8890');

-- Erebor Mining & Forge Co. (Dwarf mountain theme)
DECLARE @EreborID INT;

INSERT INTO dbo.Customers (CompanyName, PhoneNumber, Address1, City, StateOrProvince, PostalCode, Country)
VALUES ('Erebor Mining & Forge Co.', '(555) 444-3333', 'The Lonely Mountain', 'Erebor', 'The Iron Hills', '00040', 'Middle-earth');

SET @EreborID = SCOPE_IDENTITY();

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@EreborID, 'Lonely Mountain Forge', 'Deep Halls', 'Erebor', 'The Iron Hills', '00040', 'Middle-earth', '(555) 444-3334');

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@EreborID, 'Iron Hills Outpost', 'Eastern Mines', 'Iron Hills', 'The Iron Hills', '00041', 'Middle-earth', '(555) 444-3335');

-- Rohan Equestrian Logistics (Horse-lords theme)
DECLARE @RohanID INT;

INSERT INTO dbo.Customers (CompanyName, PhoneNumber, Address1, City, StateOrProvince, PostalCode, Country)
VALUES ('Rohan Equestrian Logistics', '(555) 222-1111', 'Golden Hall', 'Edoras', 'Rohan', '00050', 'Middle-earth');

SET @RohanID = SCOPE_IDENTITY();

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@RohanID, 'Edoras Stables HQ', 'Meduseld Courtyard', 'Edoras', 'Rohan', '00050', 'Middle-earth', '(555) 222-1112');

INSERT INTO dbo.Sites (CustomerID, SiteName, Address1, City, StateOrProvince, PostalCode, Country, SitePhoneNumber)
VALUES (@RohanID, 'Helm''s Deep Depot', 'Deeping Wall', 'Helm''s Deep', 'Rohan', '00051', 'Middle-earth', '(555) 222-1113');

PRINT '✅ 3 additional LOTR-themed companies + 6 sites inserted successfully!';
GO
PRINT '✅ LOTR-themed customers, sites, and contacts inserted successfully!';
GO

-- =============================================
-- LOTR-Themed Employees (7 epic team members)
-- =============================================
PRINT 'Merging LOTR-themed Employees...';

MERGE dbo.Employees AS Target
USING (VALUES
    ('Gandalf', 'the Grey', 'Gandalf the Grey', 'gandalf@istari.it', 'Chief Wizard Architect', 1),
    ('Legolas', 'Greenleaf', 'Legolas Greenleaf', 'legolas@woodland.net', 'Elven Network Ranger', 1),
    ('Gimli', 'son of Glóin', 'Gimli son of Glóin', 'gimli@erebor.hardware', 'Dwarven Infrastructure Engineer', 1),
    ('Galadriel', 'of Lothlórien', 'Galadriel', 'galadriel@lorien.security', 'Lady of Light - Security Director', 1),
    ('Aragorn', 'Elessar', 'Aragorn Elessar', 'aragorn@gondor.ops', 'Ranger Operations Manager', 1),
    ('Pippin', 'Took', 'Peregrin Took', 'pippin@shiretech.com', 'Junior Field Technician', 1),
    ('Éowyn', 'of Rohan', 'Éowyn', 'eowyn@rohan.support', 'Shieldmaiden Support Lead', 1)
) AS Source (FirstName, LastName, DisplayName, Email, JobTitle, IsActive)
ON Target.Email = Source.Email
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FirstName, LastName, DisplayName, Email, JobTitle, IsActive)
    VALUES (Source.FirstName, Source.LastName, Source.DisplayName, Source.Email, Source.JobTitle, Source.IsActive);
GO

-- =============================================
-- LOTR-Themed Assignment Groups
-- =============================================
PRINT 'Merging LOTR-themed Assignment Groups...';

MERGE dbo.AssignmentGroups AS Target
USING (VALUES
    ('The Fellowship Help Desk', 'fellowship@middleearth.it'),
    ('The Riders of Rohan', 'rohan.support@middleearth.it'),
    ('The Istari Council', 'wizards@istari.it'),
    ('The Rangers of the North', 'rangers@gondor.ops')
) AS Source (GroupName, GroupEmail)
ON Target.GroupName = Source.GroupName
WHEN NOT MATCHED BY TARGET THEN
    INSERT (GroupName, GroupEmail) VALUES (Source.GroupName, Source.GroupEmail);
GO

-- =============================================
-- Link Employees to Groups (Membership)
-- =============================================
PRINT 'Linking employees to groups...';

DECLARE @FellowshipID INT   = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Fellowship Help Desk');
DECLARE @RohanID INT        = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Riders of Rohan');
DECLARE @IstariID INT       = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Istari Council');
DECLARE @RangersID INT      = (SELECT AssignmentGroupID FROM dbo.AssignmentGroups WHERE GroupName = 'The Rangers of the North');

-- Get Employee IDs
DECLARE @GandalfID INT      = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'gandalf@istari.it');
DECLARE @LegolasID INT      = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'legolas@woodland.net');
DECLARE @GimliID INT        = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'gimli@erebor.hardware');
DECLARE @GaladrielID INT    = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'galadriel@lorien.security');
DECLARE @AragornID INT      = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'aragorn@gondor.ops');
DECLARE @PippinID INT       = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'pippin@shiretech.com');
DECLARE @EowynID INT        = (SELECT EmployeeID FROM dbo.Employees WHERE Email = 'eowyn@rohan.support');

MERGE dbo.EmployeeGroupMemberships AS Target
USING (VALUES
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
