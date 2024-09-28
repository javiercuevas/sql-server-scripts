SELECT TOP 10
	OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
	OBJECT_NAME(object_id) AS [ObjectName],
	[name] AS [StatisticName],
	STATS_DATE([object_id], [stats_id]) AS [StatisticUpdateDate],
	'UPDATE STATISTICS ' + OBJECT_SCHEMA_NAME(object_id) + '.' + OBJECT_NAME(object_id) + ' ' + [name] + ';'
FROM sys.stats
WHERE 1=1
	AND OBJECT_NAME(object_id) NOT LIKE '%[0-9][0-9][0-9][0-9]%'
	AND STATS_DATE([object_id], [stats_id]) <= DATEADD(DAY, - 7, CURRENT_TIMESTAMP)


	--UPDATE STATISTICS Stage.PreForeclosure_IN _WA_Sys_00000001_00CA12DE WITH FULLSCAN