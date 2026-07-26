USE master;
GO

----------------------------------------------------
-- Create Windows Logins (if they do not exist)
----------------------------------------------------

IF NOT EXISTS (
    SELECT * FROM sys.server_principals
    WHERE name = N'ASTERA-DEV\svc_sql'
)
CREATE LOGIN [ASTERA-DEV\svc_sql] FROM WINDOWS;
GO

IF NOT EXISTS (
    SELECT * FROM sys.server_principals
    WHERE name = N'ASTERA-DEV\sql_adm'
)
CREATE LOGIN [ASTERA-DEV\sql_adm] FROM WINDOWS;
GO

----------------------------------------------------
-- Create Users in master
----------------------------------------------------

USE master;
GO

IF NOT EXISTS (
    SELECT * FROM sys.database_principals
    WHERE name = N'ASTERA-DEV\svc_sql'
)
CREATE USER [ASTERA-DEV\svc_sql]
FOR LOGIN [ASTERA-DEV\svc_sql];
GO

IF NOT EXISTS (
    SELECT * FROM sys.database_principals
    WHERE name = N'ASTERA-DEV\sql_adm'
)
CREATE USER [ASTERA-DEV\sql_adm]
FOR LOGIN [ASTERA-DEV\sql_adm];
GO

----------------------------------------------------
-- Allow svc_sql to impersonate sql_adm
----------------------------------------------------

GRANT IMPERSONATE
ON LOGIN::[ASTERA-DEV\sql_adm]
TO [ASTERA-DEV\svc_sql];
GO

----------------------------------------------------
-- Server Permissions
----------------------------------------------------

GRANT CONNECT SQL
TO [ASTERA-DEV\sql_adm];
GO

GRANT VIEW ANY DATABASE
TO [ASTERA-DEV\sql_adm];
GO

GRANT VIEW SERVER STATE
TO [ASTERA-DEV\sql_adm];
GO

----------------------------------------------------
-- Server Roles
----------------------------------------------------

ALTER SERVER ROLE [dbcreator]
ADD MEMBER [ASTERA-DEV\sql_adm];
GO

ALTER SERVER ROLE [processadmin]
ADD MEMBER [ASTERA-DEV\sql_adm];
GO

ALTER SERVER ROLE [bulkadmin]
ADD MEMBER [ASTERA-DEV\sql_adm];
GO

----------------------------------------------------
-- Verification
----------------------------------------------------

PRINT '=== Logins ===';

SELECT
    name,
    type_desc
FROM sys.server_principals
WHERE name LIKE 'ASTERA-DEV%';
GO

PRINT '=== Server Roles ===';

SELECT
    sp.name AS LoginName,
    sr.name AS ServerRole
FROM sys.server_role_members rm
JOIN sys.server_principals sr
ON rm.role_principal_id = sr.principal_id
JOIN sys.server_principals sp
ON rm.member_principal_id = sp.principal_id
WHERE sp.name LIKE 'ASTERA-DEV%';
GO

PRINT '=== Permissions ===';

SELECT
    permission_name,
    state_desc,
    USER_NAME(grantee_principal_id) AS Grantee
FROM sys.server_permissions;
GO
