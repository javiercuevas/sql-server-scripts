/*
https://blog.zubairalexander.com/how-to-fix-sql-server-databases-in-suspect-or-recovery-pending-mode/
*/

EXEC sp_resetstatus  DBName

ALTER DATABASE DBName SET EMERGENCY DBCC checkdb('DBName')

ALTER DATABASE DBName SET SINGLE_USER WITH ROLLBACK IMMEDIATE

DBCC CheckDB('DBName',REPAIR_ALLOW_DATA_LOSS)

ALTER DATABASE DBAName SET MULTI_USER

EXEC sp_resetstatus DBName