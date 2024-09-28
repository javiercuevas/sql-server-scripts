----------------------------------------------------------
-- really simple missing indexes query
-- shows missing indexes for all db's on server
-- i usually create an index on both the fields lised
-- in the equality_columns and inequality_colums
-- the included columns recomendations are filtered out
-- as they produce noise/junk
----------------------------------------------------------

--------------------------------------------------------
-- a list of tables in the db and their row counts
--------------------------------------------------------
declare	@TableInfo table (database_id int, object_id int, TableSchema VARCHAR(100), TableName varchar(1000), RowCounts int, DataSpaceMB int)
insert into @TableInfo
select
		db_id(),
		t.object_id, 
		schema_name(t.schema_id) AS table_schema,
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
		schema_name(t.schema_id),
		t.name, 
		i.object_id, 
		i.index_id, 
		i.name 
order by 
		object_name(i.object_id) 

--------------------------------------------------------
-- missing index query
--------------------------------------------------------
select		db_name(mi.database_id) as DB,
			ti.TableSchema,
			object_name(mi.object_id, mi.database_id) as TableName,
			ti.RowCounts,
			mi.equality_columns,
			mi.inequality_columns ,
			mi.included_columns,
			'create index IDX_' 
				--+ object_name(mi.object_id, mi.database_id) + '_'
				+ replace(replace(replace(mi.equality_columns, '[', ''), ']', ''), ', ', '_')
				+ case when mi.included_columns is null then '' else '_Inc' end
				+ ' on ' + SCHEMA_NAME(mi.object_id) + '.' + OBJECT_NAME (mi.object_id, mi.database_id)
				+ '(' + mi.equality_columns + ')'
				+ 
				-- if user wants to use included column indexes
				case
					when mi.included_columns is null
					then ''
					else 
						' include ('
						+ mi.included_columns
						+ ')'
				end
			as IndexCreate,
			'drop index IDX_' 
				--+ object_name(mi.object_id, mi.database_id) + '_'
				+ replace(replace(replace(mi.equality_columns, '[', ''), ']', ''), ', ', '_')
				+ case when mi.included_columns is null then '' else '_Inc' end
				+ ' on ' + SCHEMA_NAME(mi.object_id) + '.' + OBJECT_NAME (mi.object_id, mi.database_id)
			as IndexDrop
from		sys.dm_db_missing_index_details mi
left join	@TableInfo ti on ti.database_id = mi.database_id and ti.Object_Id = mi.object_id
where		1=1
			and equality_columns is not null
			and inequality_columns is null
			and included_columns is null
			--and db_name(database_id) like 'Co%'
order by	3 desc
