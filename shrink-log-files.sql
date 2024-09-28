--------------------------------------------------
-- CoAMC
--------------------------------------------------
use CoAMC
go

-- this database has transaction log backups
-- so the shrink should work
-- sql will shrink log after it sees 2+ consecutive log backups
dbcc shrinkfile('CoBlankDB_log', 1000)
go


--------------------------------------------------
-- CoSystem
--------------------------------------------------
use CoSystem
go

--set db to simple then back to full for a split second
--doing this allows the log to be shrunk
--since log backups are not taking place on this db
alter database CoSystem set recovery simple
go

alter database CoSystem set recovery full
go

-- set log to 100 MB
dbcc shrinkfile('CoSystem_log', 100)
go