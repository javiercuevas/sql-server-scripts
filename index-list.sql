------------------------------------------------
-- this script lists all the custom ceojuice
-- indexes, sorted by table, index name
-- updated: 2014-10-21
------------------------------------------------
select		t.name as TableName,
			i.name as IndexName
from		sys.indexes i
inner join  sys.tables t on t.object_id = i.object_id
where		1=1
			and i.name like 'IX_Custom_%'
order by	t.name, i.name

