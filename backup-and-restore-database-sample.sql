USE Master
GO

--------------------------------------------------------
-- with init option to overwrite previous backup
--------------------------------------------------------
backup database CEOJuice
to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\Backup\CEOJuice.bak'
with 
init, 
compression,
stats = 10;

--------------------------------------------------------
-- restore db clone
--------------------------------------------------------
restore database CEOJuice_Clone
from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\Backup\CEOJuice.bak'
with 
stats = 10, 
recovery,
move 'CEOJuice' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\CEOJuice_Clone.mdf',
move 'CEOJuice_Log' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\CEOJuice_Clone_log.ldf'

--------------------------------------------------------
-- set to simple recovery
--------------------------------------------------------
ALTER DATABASE CEOJuice_Clone SET RECOVERY SIMPLE
GO

--------------------------------------------------------
-- shrink any excess log file in the clone
--------------------------------------------------------
USE CEOJuice_Clone
GO

DBCC SHRINKFILE('CEOJuice_log', 100)
GO
