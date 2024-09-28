----------------------------------------------------
-- lists out the cpu % taken up by each database
-- data aggregated from query plan cache
----------------------------------------------------
begin
set nocount on
set transaction isolation level read uncommitted;

with DB_CPU_Stats
as
(
select		DatabaseID, 
			db_name(DatabaseID) as [DatabaseName], 
			sum(total_worker_time) as [CPU_Time_Ms]
from		sys.dm_exec_query_stats as qs
cross apply (
				select convert(int, value) as [DatabaseID] 
				from sys.dm_exec_plan_attributes(qs.plan_handle)
				where attribute = N'dbid') as F_DB
				group by DatabaseID
			)
select		row_number() over(order by [CPU_Time_Ms] desc) as [RowNum],
			DatabaseName, 
			[CPU_Time_Ms], 
			cast([CPU_Time_Ms] * 1.0 / sum([CPU_Time_Ms]) OVER() * 100.0 as decimal(5, 2)) as [CPU_Percent]
from		DB_CPU_Stats
where		DatabaseID > 4 -- system databases
and			DatabaseID <> 32767 -- ResourceDB
order by	RowNum option (recompile);

end;