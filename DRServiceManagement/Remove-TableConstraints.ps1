<#
.SYNOPSIS
    Connects to an Azure SQL Database and drops all user tables by dynamically
    generating DROP statements for constraints and tables.
.DESCRIPTION
    This is the Azure SQL Database-compatible version. It is a destructive script 
    designed to completely reset a database schema.

    What's Different and Why It Works
    No sp_msforeachtable: The script no longer references the non-existent stored procedure.

    Querying sys.foreign_keys: It directly queries this system view to get the name and parent table of every foreign key in your database.

    Querying sys.tables: It queries this view to get the name of every user-created table (WHERE type = 'U').

    Dynamic SQL Generation: For each row found in the system views, it constructs a valid ALTER TABLE ... DROP CONSTRAINT or DROP TABLE statement as a string.

    Concatenation: All of these individual DROP statements are concatenated into a single, large string held in the @sql variable.

    sp_executesql: This is a standard and secure stored procedure that executes a string of T-SQL. We use it to run the entire batch of DROP commands that we just built.

    This approach is more modern, more reliable, and is the standard way to perform this kind of dynamic database operation in Azure SQL. My apologies again for the initial error, and thank you for pointing it out.
#>

# --- Configuration ---
$sqlServerName = "your-sql-server-name.database.windows.net" # <-- UPDATE THIS
$databaseName = "your-database-name"                         # <-- UPDATE THIS
$sqlAdminUser = "your-sql-admin-username"                    # <-- UPDATE THIS

# --- DANGER: Safety Check ---
Write-Host -ForegroundColor Yellow "WARNING: This script will delete all tables from the database '$databaseName'."
$confirmation = Read-Host "Type the database name to confirm you want to proceed"

if ($confirmation -ne $databaseName) {
    Write-Host -ForegroundColor Red "Confirmation failed. Aborting script."
    return
}

# --- Securely Get Credentials ---
Write-Host "Please enter the password for the SQL user '$sqlAdminUser':"
$password = Read-Host -AsSecureString

# --- Define the Azure SQL-Compatible Teardown Query ---
# This version queries system views to build the drop commands dynamically.
$teardownQuery = @"
DECLARE @sql NVARCHAR(MAX) = N'';

-- ===================================================================
--  Step 1: Generate commands to drop all foreign key constraints
-- ===================================================================
PRINT 'Generating commands to drop foreign key constraints...';

-- Build a single string containing all DROP CONSTRAINT statements
SELECT @sql += 'ALTER TABLE ' 
    + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) 
    + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) 
    + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys;

PRINT 'Executing DROP CONSTRAINT commands...';
-- Execute all the generated commands at once
EXEC sp_executesql @sql;
PRINT 'All foreign key constraints dropped.';


-- ===================================================================
--  Step 2: Generate commands to drop all user tables
-- ===================================================================
PRINT 'Generating commands to drop all user tables...';

-- Reset the @sql variable to be empty
SET @sql = N'';

-- Build a single string containing all DROP TABLE statements
SELECT @sql += 'DROP TABLE ' 
    + QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) 
    + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.tables 
WHERE type = 'U'; -- 'U' specifies only user tables

PRINT 'Executing DROP TABLE commands...';
-- Execute all the generated commands at once
EXEC sp_executesql @sql;
PRINT 'All user tables have been dropped.';
GO
"@

# --- Execute the Query ---
try {
    Write-Host "Connecting to database '$databaseName' to execute teardown script..."
    Invoke-Sqlcmd -ServerInstance $sqlServerName `
        -Database $databaseName `
        -Username $sqlAdminUser `
        -Password $password `
        -Query $teardownQuery `
        -SuppressProviderContextWarning

    Write-Host -ForegroundColor Green "Database teardown complete. All tables have been dropped successfully."

} catch {
    Write-Host -ForegroundColor Red "An error occurred during script execution."
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}
