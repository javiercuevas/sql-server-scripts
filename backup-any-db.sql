--set your db
use YourDBName
go

--variables
declare @DateString varchar(100)
declare	@DBName varchar(100)
declare	@FilePath varchar(1000)

--clean up seperators to underscores
set @DateString = convert(varchar, current_timestamp, 121)
set @DateString = replace(@DateString, '-', '_')
set @DateString = replace(@DateString, ':', '_')
set @DateString = replace(@DateString, '.', '_')

-- trim last ms digit
set	@DateString = substring(@DateString, 1, len(@DateString)-1)

--set current db selected
set @DBName = db_name()

--create full file path for backup
set	@FilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\Backup\' + @DBname + '_' + @DateString + '.bak'

--select	@FilePath


backup database Test
to disk = @FilePath
with compression
