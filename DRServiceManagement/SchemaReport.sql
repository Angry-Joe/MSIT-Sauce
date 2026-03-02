-- === FULL DATABASE SCHEMA REPORT (Fixed Version) ===
-- Run this AFTER your full script has finished

SELECT
    t.name AS [Table],
    c.name AS [Column],
    ty.name AS [Data Type],
    CASE
        WHEN c.max_length = -1 THEN 'MAX'
        WHEN ty.name IN ('nchar','nvarchar') THEN CAST(c.max_length / 2 AS VARCHAR(10))
        ELSE CAST(c.max_length AS VARCHAR(10))
    END AS [Length],
    CASE WHEN c.is_nullable = 1 THEN 'YES' ELSE 'NO' END AS [Nullable],
    CASE WHEN pk.is_primary_key = 1 THEN 'YES' ELSE '' END AS [Primary Key],
    OBJECT_NAME(fk.referenced_object_id) AS [References Table],
    COL_NAME(fk.referenced_object_id, fk.referenced_column_id) AS [References Column],
    ISNULL(OBJECT_DEFINITION(c.default_object_id), '') AS [Default Value]
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
LEFT JOIN sys.types ty ON c.user_type_id = ty.user_type_id
LEFT JOIN (
    SELECT ic.object_id, ic.column_id, 1 AS is_primary_key
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    WHERE i.is_primary_key = 1
) pk ON c.object_id = pk.object_id AND c.column_id = pk.column_id
LEFT JOIN sys.foreign_key_columns fk ON c.object_id = fk.parent_object_id
    AND c.column_id = fk.parent_column_id
WHERE t.is_ms_shipped = 0
ORDER BY t.name, c.column_id;