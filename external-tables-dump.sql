SELECT SCHEMA_NAME(schema_id) AS SchemaName, name AS TableName,
		'SELECT TOP 1 * FROM ' + '[' + SCHEMA_NAME(schema_id) + '].[' + name + ']'
FROM sys.tables
WHERE	is_external = 1
ORDER BY 1, 2