-------------------------------------------------------------------
-- lists the top queries consuming cpu worker time
-- this result includes queries in ALL databases
-------------------------------------------------------------------
select			top 25	
				db_name(pl.dbid) as db_name,
				qs.creation_time,
				qs.last_execution_time,
				qs.total_physical_reads,
				qs.total_logical_reads, 
				qs.total_logical_writes,
				qs.execution_count,
				qs.total_worker_time,
				qs.min_elapsed_time,
				qs.last_worker_time,
				qs.total_elapsed_time,
				qs.total_elapsed_time / qs.execution_count as avg_elapsed_time,
				cast(qs.min_elapsed_time  / 1000000.0 as decimal(10,2)) as min_elapsed_time_in_secs,
				cast(qs.last_worker_time / 1000000.0 as decimal(10,2))  as last_worker_time_in_secs,
				--cast(last_worker_time * execution_count / 1000000.0 as decimal(10,2))  as total_est_time_in_secs,
				substring(st.text, (qs.statement_start_offset/2) + 1,
			 	((case qs.statement_end_offset
			  	when -1 then datalength(st.text)
			  	else qs.statement_end_offset end
				- qs.statement_start_offset)/2) + 1) as statement_text,
				qs.plan_handle,
				pl.query_plan
from			sys.dm_exec_query_stats as qs
cross apply 	sys.dm_exec_sql_text(qs.sql_handle) st
cross apply		sys.dm_exec_query_plan(qs.plan_handle) pl
where			1=1
				--and object_name(st .objectid) is not null
				and qs.last_execution_time > dateadd(minute, -30, current_timestamp)
order by			--qs.min_elapsed_time desc
				--qs.last_worker_time desc
				---total_est_time_in_secs desc
				qs.execution_count desc

option			(maxdop 2)