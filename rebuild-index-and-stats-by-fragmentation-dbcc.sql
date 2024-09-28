declare	@MySchema			varchar(255)
declare @MyTable			varchar(255)
declare	@MyIndex			varchar(255)
declare	@MyFragmentation	decimal(10,2)
declare	@Cmd				varchar(4000)

------------------------------------------------------
-- list of fragmented indexes
------------------------------------------------------
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
where		indexstats.avg_fragmentation_in_percent >= 30
order by	indexstats.avg_fragmentation_in_percent desc

------------------------------------------------------
-- clustered and non-clustered indexes cursor
------------------------------------------------------
declare		myCursor1 cursor for
select		SchemaName, TableName, IndexName, FragentationPercent
from		@ResultsTable
where		IndexType <> 'HEAP'
			and IndexName is not null
order by	FragentationPercent desc

------------------------------------------------------
-- clustered and non-clustered indexes execs
------------------------------------------------------
print '----------------------------------------'
print 'Clustered and Non-Clustered Indexes'
print '----------------------------------------'

open myCursor1
	fetch next
	from myCursor1 into @MySchema, @MyTable, @MyIndex, @MyFragmentation
	while @@fetch_status = 0
		begin
		set @Cmd = 'dbcc dbreindex(' + '''' + + @MySchema + '.' + @MyTable + '''' + ', ' +  '''' + @MyIndex + '''' + ', 80)'
		print @Cmd
		--exec (@Cmd)
		fetch	next
		from	myCursor1 into @MySchema, @MyTable, @MyIndex, @MyFragmentation
	end
close myCursor1
deallocate myCursor1

------------------------------------------------------
-- heaps cursor
------------------------------------------------------
declare		myCursor2 cursor for
select		distinct SchemaName, TableName, FragentationPercent
from		@ResultsTable
where		IndexType = 'HEAP'

------------------------------------------------------
-- heaps execs
------------------------------------------------------

print '----------------------------------------'
print 'Heaps'
print '----------------------------------------'

open myCursor2
	fetch next
	from myCursor2 into @MySchema, @MyTable, @MyFragmentation
	while @@fetch_status = 0
		begin
		set @Cmd = 'dbcc dbreindex(' + '''' + @MySchema + '.' + @MyTable + '''' + ', ' +  '''''' + ', 80)'
		print @Cmd
		--exec (@Cmd)
		fetch	next
		from	myCursor2 into @MySchema, @MyTable, @MyFragmentation
	end
close myCursor2
deallocate myCursor2

------------------------------------------------------
-- statistics
------------------------------------------------------
print '----------------------------------------'
print 'Statistics'
print '----------------------------------------'

--exec sp_updatestats