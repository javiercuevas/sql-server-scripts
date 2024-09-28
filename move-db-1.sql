USE MASTER;
GO

--------------------------------------------------------------------
-- Take database in single user mode -- if you are facing errors
-- This may terminate your active transactions for database
--------------------------------------------------------------------
ALTER DATABASE Test2
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

--------------------------------------------------------------------
-- Detach DB
--------------------------------------------------------------------
EXEC MASTER.dbo.sp_detach_db @dbname = 'Test2'
GO

--------------------------------------------------------------------
-- Manually move files to new location
--------------------------------------------------------------------

--------------------------------------------------------------------
-- Move MDF File from Loc1 to Loc 2
-- Re-Attached DB
--------------------------------------------------------------------
CREATE DATABASE Test2 ON
( FILENAME = 'C:\DB\Test2.mdf' ),
( FILENAME = 'C:\DB\Test2_log.ldf' )
FOR ATTACH
GO

--------------------------------------------------------------------
-- view info
--------------------------------------------------------------------
select  name, physical_name, size / 128 as mb
from    sys.database_files