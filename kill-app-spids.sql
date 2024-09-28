declare	@kill varchar(8000) = ''

select	@kill + 'kill ' + convert(varchar, session_id)
from	sys.dm_exec_sessions
where	1=1
		and database_id = db_id('CoTest')
		and program_name = 'REMOTETECH'

print @kill

--exec (@kill)