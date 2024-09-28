CREATE DATABASE Test
ON 
(FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016\MSSQL\DATA\Test.mdf'), 
(FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016\MSSQL\DATA\Test_log.ldf') 
FOR ATTACH
GO

CREATE DATABASE Test2
ON 
(FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016\MSSQL\DATA\Test2.mdf'), 
(FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016\MSSQL\DATA\Test2_log.ldf') 
FOR ATTACH
GO