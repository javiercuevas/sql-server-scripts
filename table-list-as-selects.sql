SELECT	SCHEMA_NAME(t.schema_id) AS SchemaName, t.name AS TableName,
		'SELECT TOP 5 * FROM ' + '[' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + ']' AS SqlScript
FROM	sys.tables t
WHERE	is_external = 0
ORDER BY 1, 2