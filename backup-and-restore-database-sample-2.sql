USE Master
GO

--------------------------------------------------------
-- with init option to overwrite previous backup
--------------------------------------------------------
backup database CoSample
to disk = 'F:\Backups\CoSample_Snapshot\CoSample.bak'
with 
copy_only,
init, 
compression,
stats = 10;


--------------------------------------------------------
-- set to single
--------------------------------------------------------
ALTER DATABASE CoSample_Snapshot
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE
GO

--------------------------------------------------------
-- restore db clone
--------------------------------------------------------
restore database CoSample_Snapshot
from disk = 'F:\Backups\CoSample_Snapshot\CoSample.bak'
with 
stats = 10, 
replace,
recovery,
move 'CoBlankDB' to 'F:\Data\CoSample_Snapshot\CoSample_Snapshot.mdf',
move 'CoBlankDB_Log' to 'F:\Data\CoSample_Snapshot\CoSample_Snapshot_log.ldf'
GO

--------------------------------------------------------
-- set back to multi
--------------------------------------------------------
ALTER DATABASE CoSample_Snapshot
SET MULTI_USER
GO

--------------------------------------------------------
-- set service account rights
--------------------------------------------------------

Use CoSample_Snapshot
CREATE USER MySampleUser For LOGIN MySampleUser
EXEC sp_addrolemember 'db_datareader', 'MySampleUser'

--------------------------------------------------------
-- set to simple recovery
--------------------------------------------------------
ALTER DATABASE CoSample_Snapshot SET RECOVERY SIMPLE
GO

--------------------------------------------------------
-- shrink any excess log file in the clone (if needed)
--------------------------------------------------------
USE CoSample_Snapshot
GO

DBCC SHRINKFILE('CoBlankDB_log', 2000)
GO
