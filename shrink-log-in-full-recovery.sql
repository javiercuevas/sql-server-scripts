USE CoClient
GO

ALTER DATABASE CoClient SET RECOVERY SIMPLE
GO

ALTER DATABASE CoClient SET RECOVERY FULL
GO

-- set log to 8000 MB
DBCC SHRINKFILE('CoBlankDB_log', 8000)
GO
