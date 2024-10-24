-------------------------------------------------------------------
-- lists the top stored procedures consuming cpu worker time
-- this result includes procs in the CURRENT set database
-------------------------------------------------------------------
set transaction isolation level read uncommitted

select			top 50
				creation_time ,
				last_execution_time ,
				execution_count ,
				total_physical_reads,
				total_logical_reads, 
				total_logical_writes,
				min_elapsed_time,
				last_worker_time,
				cast(min_elapsed_time  / 1000000.0 as decimal(10,2)) as min_elapsed_time_in_secs,
				cast(last_worker_time / 1000000.0 as decimal(10,2))  as last_worker_time_in_secs,
				--cast(last_worker_time * execution_count / 1000000.0 as decimal(10,2))  as total_est_time_in_secs,
				object_name(st .objectid) as proc_name, 
				qs.plan_handle,
				pl.query_plan
from			sys. dm_exec_query_stats AS qs
cross apply		sys. dm_exec_sql_text(qs.sql_handle) st
cross apply		sys.dm_exec_query_plan(qs.plan_handle) pl
where			1=1
				and object_name(st .objectid) is not null
				
				--and object_name(st.objectid) = 'stpfactEntityEvent'
								--and object_name(st .objectid) like '%void%'
				--last 4 hours by default
				and last_execution_time > dateadd(minute, -120, current_timestamp)
order by		qs.last_worker_time desc
				--total_est_time_in_secs desc
option          (maxdop 2)
