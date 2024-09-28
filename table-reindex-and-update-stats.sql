--------------------------------------------------------------------
-- rebuilds indexes over certain percent fragmented (x%)
-- then reorganizes indexes over x% fragemented
-- then rebuilds heap tables over x% fragmented
-- then does a stats update with fullscan
--------------------------------------------------------------------

begin 
set nocount on

declare @RebuildIndexesAt           int = 95
declare @ReorganizeIndexesAt        int = 35
declare @RebuildHeapTablesAt        int = 35

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
where		ind.object_id not in 
			(
			select object_id
			from	sys.external_tables
			)
order by	indexstats.avg_fragmentation_in_percent desc


------------------------------------------------------------------------
-- clustered and non-clustered indexes cursor (rebuild) 
-- optional for deeper nightly tuning
-- commented out since rebuild locks tables, reorganize less likely
------------------------------------------------------------------------
declare		myCursor1 cursor for
select		SchemaName, TableName, IndexName, FragentationPercent
from		@ResultsTable
where		IndexType <> 'HEAP'
			and IndexName is not null
			and FragentationPercent >= @RebuildIndexesAt
order by	FragentationPercent desc


print '--------------------------------------------------'
print 'Clustered and Non-Clustered Indexes (Rebuild)'
print '--------------------------------------------------'

open myCursor1
	fetch next
	from myCursor1 into @MySchema, @MyTable, @MyIndex, @MyFragmentation
	while @@fetch_status = 0
		begin
		set @Cmd = 'alter index ' + @MyIndex  + ' on ' + @MySchema + '.' + @MyTable + ' rebuild'
		print @Cmd
		exec (@Cmd)
		fetch	next
		from	myCursor1 into @MySchema, @MyTable, @MyIndex, @MyFragmentation
	end
close myCursor1
deallocate myCursor1

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
			and FragentationPercent >= @RebuildHeapTablesAt
order by	FragentationPercent desc

print '----------------------------------------'
print 'Heaps'
print '----------------------------------------'

open myCursor3
	fetch next
	from myCursor3 into @MySchema, @MyTable, @MyFragmentation
	while @@fetch_status = 0
		begin
		set @Cmd = 'alter index all'  + ' on ' + @MySchema + '.' + @MyTable + ' rebuild'
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
select	table_name
from	information_schema.tables
where	table_type = 'base table'
		and table_schema = 'dbo'
		
print '----------------------------------------'
print 'Statistics'
print '----------------------------------------'
open myCursor4
	fetch next
	from myCursor4 into @MyTable
	while @@fetch_status = 0
		begin
		print	'Updating Stats on:  ' + @MyTable
		set @Cmd = 'update statistics ' + @MyTable + ' with sample 50 percent'
		exec(@Cmd)
		fetch	next
		from	myCursor4 into @MyTable
	end
close myCursor4
deallocate myCursor4


end