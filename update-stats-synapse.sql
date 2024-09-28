SET NOCOUNT ON
SELECT
	'UPDATE STATISTICS ' + t.SchemaName + '.' + t.TableName + ' WITH SAMPLE 25 PERCENT' + CHAR(10) + 'GO'
FROM
(
SELECT
	 SCHEMA_NAME(sOBJ.schema_id) AS SchemaName
	,sOBJ.name AS TableName
	, SUM(sPTN.Rows) AS [RecordCount]
FROM 
	sys.objects AS sOBJ
	INNER JOIN sys.partitions AS sPTN
			ON sOBJ.object_id = sPTN.object_id
WHERE
	sOBJ.type = 'U'
	AND sOBJ.is_ms_shipped = 0x0
	AND index_id < 2 -- 0:Heap, 1:Clustered	
	AND sOBJ.name  NOT IN ('Test')
	AND sOBJ.name NOT LIKE 'Adaptiv%'
	AND sOBJ.name NOT LIKE '%Soap%'
	AND sOBJ.name <> 'InitialTranche'
			
	AND sOBJ.name NOT LIKE '[0-9][0-9][0-9][0-9]%'
	AND sOBJ.name NOT LIKE '%[_][A-Z][A-Z]'
	AND SCHEMA_NAME(sOBJ.schema_id)  NOT IN ('Testing')
GROUP BY 
	sOBJ.schema_id
	, sOBJ.name

) t
ORDER BY [SchemaName], [TableName]

 