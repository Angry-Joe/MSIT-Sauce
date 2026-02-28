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

-- You would write this directly in a .sql file in VS Code
INSERT INTO ServiceTickets
    (TicketID, Description, AssignedTo)
VALUES
    ('TICKET-002', 'VPN connection is failing.', 'Network Team');

CREATE TABLE Incidents
(
    -- Column Name      Data Type         Constraints
    IncidentID INT PRIMARY KEY IDENTITY(1,1),
    SubmitterName VARCHAR(100) NOT NULL,
    ShortDescription VARCHAR(255) NOT NULL,
    DateReported DATETIME2 DEFAULT GETDATE(),
    Status VARCHAR(20) DEFAULT 'Open'
);


/*
PRIMARY KEY:
Marks IncidentID as the unique identifier for each row. No two rows can have the same IncidentID.

IDENTITY(1,1): Tells the database to automatically generate a number for IncidentID, starting at 1 and incrementing by 1 for each new record.

NOT NULL:
Ensures that SubmitterName and ShortDescription must have a value; they cannot be left empty.

DEFAULT GETDATE():
If you don't specify a time when creating a new incident, the database will automatically insert the current date and time.

DEFAULT 'Open': If you don't specify a status, it will automatically be set to 'Open'.
*/

CREATE TABLE WorkRoles
(
    -- Column Name      Data Type         Constraints
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(100) NOT NULL,
    CostHourly DECIMAL(5,2),
    DisplayOrder TINYINT,
    DateAdded DATETIME2 DEFAULT GETDATE()
);

INSERT INTO WorkRoles
    (RoleName,CostHourly,DisplayOrder)
VALUES
    ('Network Administrator',33.48,2),
    ('Network Engineer',55.8,3),
    ('Database Administrator',44.64,4),
    ('Database Engineer',66.96,5);

ALTER TABLE WorkRoles
ADD WorkGroup INT
