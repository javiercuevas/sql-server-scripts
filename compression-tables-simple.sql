--compression: row, page, none
select	object_schema_name(object_id) as SchemaName,
		name, 
		'alter table ' + '[' + object_schema_name(object_id) + ']' + '[' + name + ']' + ' rebuild partition = all with (data_compression = page)'
from	sys.tables
where	1=1
		--and schema_id = 1
		and object_schema_name(object_id) = 'Stage'
order by 1