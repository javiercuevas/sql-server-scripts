/*
https://support.microsoft.com/en-us/help/918992/how-to-transfer-logins-and-passwords-between-instances-of-sql-server
*/

--------------------------------------
-- script out logins on old server
-- on new server
--------------------------------------
use master
go
exec sp_help_revlogin --'test'

--------------------------------------
-- orphaned users report
-- on new server
--------------------------------------
Use Test 
go
exec sp_change_users_login 'report'