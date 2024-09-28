select sqltext.TEXT,
       req.session_id,
       req.status,
       req.command,
       req.cpu_time,
       req.total_elapsed_time
from   sys.dm_exec_requests req
       cross apply sys.dm_exec_sql_text(sql_handle) as sqltext 
