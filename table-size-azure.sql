with tables_cte as
(
select 
	tab.object_id,
	schema_name(tab.schema_id) + '.' + tab.name as [table],
	sum(part.rows) as [rows]
from sys.tables as tab
inner join sys.partitions as part on tab.object_id = part.object_id
where 
	part.index_id IN (1, 0) -- 0 - table without PK, 1 table with PK
	and tab.is_external = 0
group by 
	tab.object_id,
	schema_name(tab.schema_id) + '.' + tab.name
--order by 
--	sum(part.rows) desc
)


select		tab.*,
			ind.name as index_name
from			tables_cte tab
left join	sys.indexes ind on ind.object_id = tab.object_id and ind.name like 'clustered%'	
order by		tab.[rows] desc


