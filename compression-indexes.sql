
select		t.name as TableName,
			i.name as IndexName,
			'alter index ' + i.name + ' on ' + t.name + ' rebuild partition = all with (data_compression = page)'
from		sys.indexes i
inner join  sys.tables t on t.object_id = i.object_id
where		1=1
			and i.name like 'IX_%'
order by	t.name, i.name

/*
-- Returns user tables and indexes in a DB and their Compression state
select	s.name [Schema], 
		t.name [Table], 
		i.name [Index], 
		p.data_compression_desc Compression, 
		case when p.index_id in (0, 1) then 'Table' else 'Index' end CompressionObject,
		'alter index ' + i.name + ' on ' + s.name + '.' + t.name + ' rebuild partition = all with (data_compression = none)'
from	sys.tables t
join	sys.schemas s on t.schema_id = s.schema_id
join	sys.indexes i on t.object_id = i.object_id
join	sys.partitions p on (i.object_id = p.object_id and i.index_id = p.index_id)
where	t.type = 'U'
		and p.data_compression_desc = 'Row'
order by 1, 2, p.index_id, 3
*/




