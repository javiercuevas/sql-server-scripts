select  'update statistics ' + s.name + '.' + t.name + ' with fullscan' + char(10) + 'go'
from	sys.tables t
join	sys.schemas s on s.schema_id = t.schema_id
where	object_id not in 
		(
		select object_id
		from	sys.external_tables
		)