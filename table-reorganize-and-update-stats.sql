------------------------------------------------------------------------------
-- reorganizes indexes over 50% fragemented
-- then reorganizes heap tables over 50% fragmented
-- then does a stats update with fullscan on tables with % of rows changed
------------------------------------------------------------------------------

begin 
set nocount on

declare @ReorganizeIndexesAt            int = 50                -- 50% or more fragmented, reorg tables
declare @ReorganizeHeapTablesAt         int = 50                -- 50% or more fragmented, reorg heap tables
declare @UpdateStatsRowsModifiedAt      int = 5000             -- 10,000 rows or more changed in the table, then update
declare @UpdateStatsPercentModifedAt    decimal(10,4) = .001    -- 1/10th of a percent or greater of the table changed, then update
declare @UpdateStatsSamplePercent       int = 60                -- update statistics with sample rate at x%

declare	@MySchema			varchar(255)
declare @MyTable			varchar(255)
declare	@MyIndex			varchar(255)
declare	@MyFragmentation	decimal(10,2)
declare	@Cmd				varchar(4000)

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
order by	indexstats.avg_fragmentation_in_percent desc

------------------------------------------------------------------------
-- clustered and non-clustered indexes cursor (reorganize)
------------------------------------------------------------------------
declare		myCursor2 cursor for
select		SchemaName, TableName, IndexName, FragentationPercent
from		@ResultsTable
where		IndexType <> 'HEAP'
			and IndexName is not null
			and FragentationPercent >= @ReorganizeIndexesAt
order by	FragentationPercent desc

print '--------------------------------------------------'
print 'Clustered and Non-Clustered Indexes (Reorganize)' 
print '--------------------------------------------------'

open myCursor2
	fetch next
	from myCursor2 into @MySchema, @MyTable, @MyIndex, @MyFragmentation
	while @@fetch_status = 0
		begin
		set @Cmd = 'alter index ' + @MyIndex  + ' on ' + @MySchema + '.' + @MyTable + ' reorganize'
		print @Cmd
		exec (@Cmd)
		fetch	next
		from	myCursor2 into @MySchema, @MyTable, @MyIndex, @MyFragmentation
	end
close myCursor2
deallocate myCursor2

------------------------------------------------------------------------
-- heaps
------------------------------------------------------------------------
declare		myCursor3 cursor for
select		SchemaName, TableName, FragentationPercent
from		@ResultsTable
where		IndexType = 'HEAP'
			and FragentationPercent >= @ReorganizeHeapTablesAt
order by	FragentationPercent desc

print '----------------------------------------'
print 'Heaps'
print '----------------------------------------'

open myCursor3
	fetch next
	from myCursor3 into @MySchema, @MyTable, @MyFragmentation
	while @@fetch_status = 0
		begin
		set @Cmd = 'alter index all'  + ' on ' + @MySchema + '.' + @MyTable + ' reorganize'
		print @Cmd
		exec (@Cmd)
		fetch	next
		from	myCursor3 into @MySchema, @MyTable, @MyFragmentation
	end
close myCursor3
deallocate myCursor3

------------------------------------------------------------------------
-- statistics
------------------------------------------------------------------------
declare myCursor4

cursor	for
select distinct
       TableName
from   (
        select sch.name + '.' + so.name as TableName,
               ss.name as Statistic,
               sp.last_updated as StatsLastUpdated,
               sp.rows as RowsInTable,
               sp.rows_sampled as RowsSampled,
               sp.modification_counter as RowModifications
        from   sys.stats ss
               join sys.objects so on ss.object_id = so.object_id
               join sys.schemas sch on so.schema_id = sch.schema_id
               outer APPLY sys.dm_db_stats_properties(so.object_id, ss.stats_id) sp
        where  so.type = 'U'
               and sp.modification_counter > 0--change accordingly
       --ORDER BY sp.last_updated DESC
       ) t
where  RowModifications  > @UpdateStatsRowsModifiedAt
       or RowModifications / nullif(RowsInTable, 0) > @UpdateStatsPercentModifedAt
		
print '----------------------------------------'
print 'Statistics'
print '----------------------------------------'
open myCursor4
	fetch next
	from myCursor4 into @MyTable
	while @@fetch_status = 0
		begin
		print	'Updating Stats on:  ' + @MyTable
		set @Cmd = 'update statistics ' + @MyTable + ' with sample ' +  cast(@UpdateStatsSamplePercent as varchar) +  ' percent'
		exec(@Cmd)
		fetch	next
		from	myCursor4 into @MyTable
	end
close myCursor4
deallocate myCursor4


end