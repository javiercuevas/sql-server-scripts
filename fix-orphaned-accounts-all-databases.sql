----------------------------------------------------------
--more info at: 
http://www.schneider-electric.us/en/faqs/FA276686/
----------------------------------------------------------

set nocount on

----------------------------------------------------------
-- list of sql logins
----------------------------------------------------------
declare @ServerUsers table (name varchar(255))
insert into @ServerUsers
select	name
		from	master.sys.server_principals
		where	1=1
		and type in ('S', 'U')


----------------------------------------------------------
-- loop all databases to find orphaned users
----------------------------------------------------------
declare @OrphanedLogins table (DBName varchar(max), Name varchar(max), Command varchar(max))
insert into @OrphanedLogins (DBName, Name, Command)
exec sp_msforeachdb ' use ?
select db_name(), name, ''alter User ''  + name + '' with login = '' + name  from sys.database_principals 
where sid not in (select sid from master.sys.server_principals)
AND type_desc != ''DATABASE_ROLE'' AND name != ''guest'' 
'

----------------------------------------------------------
-- cursor
-- load cursor with each databases orphaned accounts
-- that exist/are valid sql logins
----------------------------------------------------------
declare @ThisDB varchar(max)
declare @ThisName varchar(max)
declare @ThisCommand varchar(max)

declare myCursor

cursor	for
select		*
from		@OrphanedLogins
where		Name in (select name from  @ServerUsers)
order by	DBName, Command
	
print '----------------------------------------'
print '--Logins To Fix'
print '----------------------------------------'
open myCursor
	fetch next
	from myCursor into @ThisDB, @ThisName, @ThisCommand
	while @@fetch_status = 0
		begin
		print	'use ' + @ThisDB
		print 'go'
		print @ThisCommand
		print 'go'
	
		fetch	next
		from	myCursor into @ThisDB, @ThisName, @ThisCommand
	end
close myCursor
deallocate myCursor

set nocount off
