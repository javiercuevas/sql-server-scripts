select
    top(25)
    text,
    creation_time,
    last_execution_time,
    CAST(( total_worker_time + 0.0 ) / 1000 AS BIGINT)                     as total_worker_time,
    CAST(( total_worker_time + 0.0 ) / ( execution_count * 1000 ) AS BIGINT) as [avg_cpu_time],
    execution_count
from
    sys.dm_exec_query_stats qs
    cross APPLY sys.dm_exec_sql_text(sql_handle) st
where
    total_worker_time > 0
order  by
    total_worker_time desc 
