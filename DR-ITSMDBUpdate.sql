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

CREATE TABLE ServiceCases
(
    CaseID INT PRIMARY KEY IDENTITY(1,1),
    FK_BusId INT,
    CustomerName NVARCHAR(100) NOT NULL,
    Channel NVARCHAR(100),
    FK_IssueState INT,
    Priority INT DEFAULT 4,
    CallerName NVARCHAR(100),
    CallerBestContactNumber NVARCHAR(50),
    CallerBestEmail NVARCHAR(255),
    FK_AssignmentGroup INT,
    FK_AssignedTo INT,
    FK_BusinessService INT,
    FK_SiteID INT,
    LocationManEntry NVARCHAR(100),
    ShortDescription NVARCHAR(255),
    Description NVARCHAR(MAX),
    WorkNotes NVARCHAR(MAX),
    DateResolved DATETIME2,
    ResolvedBy INT

    FOREIGN KEY (FK_BusID) REFERENCES dbo.Customers(BusID)
    FOREIGN KEY (FK_IssueState) REFERENCES dbo.IssueStatus(StatusID)
    FOREIGN KEY (FK_AssignmentGroup) REFERENCES Customers(BusIDNo)
    FOREIGN KEY (FK_BusIDNo) REFERENCES Customers(BusIDNo)

);

GO
CREATE TABLE IssueStatus (
    StatusID INT PRIMARY KEY IDENTITY(1,1),
    StatusDisplay NVARCHAR(30),
    DisplayOrder TINYINT
);

INSERT INTO IssueStatus(StatusDisplay,DisplayOrder)
VALUES ('Routine',1),('Priority',2),('Immediate',3),('Flash',4);
