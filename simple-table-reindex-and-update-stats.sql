declare @MyTable varchar(255)
declare	@Cmd varchar(255)
declare myCursor

cursor	for
select	table_name
from	information_schema.tables
where	table_type = 'base table'
		and table_schema = 'dbo'
		
-------------------------
-- indexes
-------------------------
open myCursor
	fetch next
	from myCursor into @MyTable
	while @@fetch_status = 0
		begin
		print	'Reindexing Table:  ' + @MyTable
		dbcc	dbreindex(@MyTable, '', 80)
		fetch	next
		from	myCursor into @MyTable
	end
close myCursor

-------------------------
-- statistics
-------------------------
open myCursor
	fetch next
	from myCursor into @MyTable
	while @@fetch_status = 0
		begin
		print	'Updating Stats on:  ' + @MyTable
		set @Cmd = 'update statistics ' + @MyTable
		exec(@Cmd)
		fetch	next
		from	myCursor into @MyTable
	end
close myCursor
deallocate myCursor
