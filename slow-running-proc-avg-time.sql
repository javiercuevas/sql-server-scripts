SELECT 
   DB_NAME(database_id) [database],
   OBJECT_NAME(object_id) [stored_procedure],
   cached_time, 
   last_execution_time, 
   execution_count,
   total_elapsed_time/ 1000000.0 / execution_count [avg_elapsed_time],
   [type_desc]
FROM sys.dm_exec_procedure_stats
WHERE OBJECT_NAME(object_id) IN ('stpfactEntityEvent')
ORDER BY avg_elapsed_time desc;