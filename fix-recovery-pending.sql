EXEC sp_resetstatus AnalyticsDB

ALTER DATABASE AnalyticsDB SET EMERGENCY DBCC checkdb('AnalyticsDB')

ALTER DATABASE AnalyticsDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE

DBCC CheckDB('AnalyticsDB' ,REPAIR_ALLOW_DATA_LOSS)

ALTER DATABASE AnalyticsDB SET MULTI_USER

EXEC sp_resetstatus AnalyticsDB