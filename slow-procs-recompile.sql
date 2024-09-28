--ALTER procedure [dbo].[admin_recompile_slow_report_procs]
--as

/*	purpose: sp_recompile slow procs
	author: JC
	date: 06/17/2014
*/

begin
set transaction isolation level read uncommitted
set nocount on

--------------------------------------------------------
-- variables for cursor loop
--------------------------------------------------------
declare		@cur_proc_name	varchar(1000)
declare		@cmd			varchar(1000)
declare		@flagged		table (cmd varchar(1000))

--------------------------------------------------------
-- store a list of slow report procs
--------------------------------------------------------
declare		@results table (
				creation_time				datetime, 
				last_execution_time			datetime,
				execution_count				int,
				min_elapsed_time_in_secs	decimal(10,2),
				last_workder_time_in_secs	decimal(10,2),
				proc_name					varchar(1000)
				)
	
--------------------------------------------------------
-- results (main group)
--------------------------------------------------------									
insert		@results
select		top 10 
			creation_time,
			last_execution_time,
			execution_count,
			cast(min_elapsed_time  / 1000000.0 as decimal(10,2)) as min_elapsed_time_in_secs,
			cast(last_worker_time / 1000000.0 as decimal(10,2)) as last_worker_time_in_secs,
			object_name(st.objectid) as proc_name
from		sys.dm_exec_query_stats AS qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
where		1=1
			--and object_name(st.objectid) like '%proc_rpt%'
			and last_worker_time > 1000000 --- 1 second(s) or longer
order by	qs.last_worker_time desc
option		(maxdop 1)


--------------------------------------------------------
-- loop through and sp_recompile slow report procs
--------------------------------------------------------
declare	proc_list cursor for select proc_name from @results

open	proc_list
		fetch next from proc_list into @cur_proc_name
		while @@fetch_status = 0
			begin
			set @cmd = 'sp_recompile ' + '''' + @cur_proc_name + ''''
			
			exec (@cmd)
			insert	@flagged values (@cmd)
			
			fetch next from proc_list into @cur_proc_name
			end
close	proc_list
deallocate proc_list

----------------------------------------
-- return table of flagged procs
----------------------------------------
select	*
from	@flagged


end


