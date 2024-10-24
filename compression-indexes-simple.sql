
select		object_schema_name(t.object_id) as SchemaName,
			t.name as TableName,
			i.name as IndexName,
			'alter index ' + i.name + ' on ' + object_schema_name(t.object_id) + '.' + t.name + ' rebuild partition = all with (data_compression = row)'
from		sys.indexes i
inner join  sys.tables t on t.object_id = i.object_id
where		1=1
			--and i.name like 'IDX_%'
			and t.name like 'FATMini%'
order by	t.name, i.name


/*
-- Returns user tables and indexes in a DB and their Compression state
select	s.name [Schema], 
		t.name [Table], 
		i.name [Index], 
		p.data_compression_desc Compression, 
		case when p.index_id in (0, 1) then 'Table' else 'Index' end CompressionObject,
		'alter index ' + i.name + ' on ' + t.name + ' rebuild partition = all with (data_compression = row)'
from	sys.tables t with (nolock)
join	sys.schemas s with (nolock) on t.schema_id = s.schema_id
join	sys.indexes i with (nolock) on t.object_id = i.object_id
join	sys.partitions p with (nolock) on (i.object_id = p.object_id and i.index_id = p.index_id)
where	t.type = 'U'
		--and p.data_compression_desc = 'Page'
		and t.name like 'FATMini%'
order by 1, 2, p.index_id, 3
*/





