USE MASTER
GO

-------------------------------------------------------------------------------------------------
-- the filename path is the NEW path
-- sql server will create new tempdb files in this new path once the sql service is restarted
-- once all looks good with the move you can delete the old tempdb files
-------------------------------------------------------------------------------------------------

ALTER DATABASE tempdb 
MODIFY FILE ( name=tempdev, filename='C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\tempdb.mdf') 
GO

ALTER DATABASE tempdb 
MODIFY FILE ( name=tempdev2, filename='C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\tempdb2.mdf') 
GO

ALTER DATABASE tempdb 
MODIFY FILE ( name=templog, filename='C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\templog.ldf') 
GO