-------------------------------------------------------
-- view missing indexes weighted by potential value:
-- this is a really detailed look at potentially missing 
-- indexes by database
-- most records are due to included columns, i'd just 
-- focus on the rows with non-null equality_columns
-- that don't contain included_columns
--------------------------------------------------------

--------------------------------------------------------
-- a list of tables in the db and their row counts
--------------------------------------------------------
set transaction isolation level read uncommitted
declare	@TableInfo table (database_id int, object_id int, TableName varchar(1000), RowCounts int, DataSpaceMB int)
insert into @TableInfo
select
		db_id(),
		t.object_id, 
		t.name AS TableName,
		sum(p.rows) AS RowCounts,
		(sum(a.data_pages) * 8) / 1024 AS DataSpaceMB
from	sys.tables t
		inner join sys.indexes i ON t.object_id = i.object_id
		inner join sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
		inner join sys.allocation_units a ON p.partition_id = a.container_id
where 1=1
		--and t.name not like 'dt%'
		and i.object_id > 255  
		and i.index_id <= 1
group by 
		t.object_id, 
		t.name, 
		i.object_id, 
		i.index_id, 
		i.name 
order by 
		object_name(i.object_id) 


--------------------------------------------------------
-- main query
--------------------------------------------------------
select		sc.name + '.' + object_name( details.object_id ),
			ti.RowCounts,
            details.equality_columns,
            details.inequality_columns,
            details.included_columns,
            stats.avg_total_user_cost,
            stats.user_seeks,
            stats.avg_user_impact,
            stats.avg_total_user_cost * stats.avg_user_impact * ( stats.user_seeks + stats.user_scans ) as potential,
			'CREATE INDEX IDX_' 
				--+ object_name(details.object_id, details.database_id) + '_'
				+ replace(replace(replace(details.equality_columns, '[', ''), ']', ''), ', ', '_')
				+ case when details.included_columns is null then '' else '_Inc' end
				+ ' ON ' + sc.name + '.' + object_name (details.object_id, details.database_id)
				+ ' (' + details.equality_columns + ')'
				+ 
				-- if user wants to use included column indexes
				case
					when details.included_columns is null
					then ''
					else 
						' include ('
						+ details.included_columns
						+ ')'
				end
			as IndexCreate,
			'drop index IX_Custom_' 
				+ object_name(details.object_id, details.database_id) + '_'
				+ replace(replace(replace(details.equality_columns, '[', ''), ']', ''), ', ', '_')
				+ case when details.included_columns is null then '' else '_Inc' end
				+ ' on ' + object_name (details.object_id, details.database_id)
			as IndexDrop
from		sys.dm_db_missing_index_group_stats stats
inner join  sys.dm_db_missing_index_groups groups on stats.group_handle = groups.index_group_handle
inner join  sys.dm_db_missing_index_details details on details.index_handle = groups.index_handle
inner join  sys.objects o on o.object_id = details.object_id
inner join  sys.schemas sc on o.schema_id = sc.schema_id
left join	@TableInfo ti on ti.database_id = details.database_id and ti.object_id = details.object_id
where       o.type_desc = 'user_table'
			and len(details.included_columns) < 75
order by    potential desc
