------------------------------------------------------------------------
-- list of fragmented indexes
------------------------------------------------------------------------
declare		@ResultsTable table (
				SchemaName			varchar(255),
				TableName			varchar(255),
				IndexName			varchar(255),
				IndexType			varchar(255),
				FragentationPercent	decimal(10,2)	
			)
insert into	@ResultsTable
select		object_schema_name(ind.object_id) as SchemaName,
			object_name(ind.object_id) AS TableName,
			ind.name AS IndexName,
			indexstats.index_type_desc AS IndexType, 
			indexstats.avg_fragmentation_in_percent
from		sys.dm_db_index_physical_stats(db_id(), null, null, null, null) indexstats 
inner join	sys.indexes ind  
				on ind.object_id = indexstats.object_id 
				and ind.index_id = indexstats.index_id 
order by	indexstats.avg_fragmentation_in_percent DESC


SELECT  DISTINCT 'ALTER INDEX ' + rt.IndexName + ' ON ' + rt.SchemaName + '.' + rt.TableName + ' REORGANIZE' + CHAR(10) + 'GO'
FROM	@ResultsTable AS rt 
WHERE	FragentationPercent	 >= 35
		AND rt.IndexName IS NOT NULL
