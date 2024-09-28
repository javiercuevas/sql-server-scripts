---------------------------------------------------------------------------------
--similar to sp_who2, this proc lists out sql statments and potential blockers
---------------------------------------------------------------------------------
begin
set nocount on;
set transaction isolation level read uncommitted;

select		case er.[statement_end_offset] 
			when -1 then
				--The end of the full command is also the end of the active statement
				substring(est.text, (er.[statement_start_offset]/2) + 1, 2147483647)
			else  
				--The end of the active statement is not at the end of the full command
				substring(est.text, (er.[statement_start_offset]/2) + 1, (er.[statement_end_offset] - er.[statement_start_offset])/2)  
			end as StatementRunning,
			est.text SQLStatement,
			isnull(er.cpu_time, es.cpu_time) CPUTime,
			isnull((er.reads + er.writes),(es.reads + es.writes)) DiskIO, 
			es.Session_ID SPID,
			isnull(er.status,es.status) Status,
			es.login_name Login,
			es.host_name HostName,
			tl.BlkBy,
			bb.host_name as BlkByHostName,
			db_name(er.Database_ID) DBName,
			er.command,
			es.last_request_start_time LastBatch,
			es.program_name,
			er.wait_type,
			er.wait_resource,
			db_name(er.Database_ID) as DBName
from		sys.dm_exec_sessions es 
			left join sys.dm_exec_requests er on es.session_id = er.session_id
			left join
			(
			select		a.request_session_id as SPID,
						b.blocking_session_id as BlkBy
			from		sys.dm_tran_locks a
			inner join	sys.dm_os_waiting_tasks b on a.lock_owner_address = b.resource_address
			) tl on es.Session_ID = tl.SPID
			left join	sys.sysprocesses sp on sp.spid = es.session_id
			outer apply	sys.dm_exec_sql_text(sp.sql_handle) est
			left join	sys.dm_exec_sessions bb on bb.session_id = tl.BlkBy
where		es.host_name is not null
order by	BlkBy desc, spid --command desc, last_batch desc, es.nt_user_name desc

end;
