SELECT AVG(avg_DTU_percent)
FROM
(
SELECT  top 60 end_time,   
  (SELECT Max(v)    
   FROM (VALUES (avg_cpu_percent), (avg_data_io_percent), (avg_log_write_percent)) AS    
   value(v)) AS [avg_DTU_percent]   
FROM sys.dm_db_resource_stats
order by 1 desc
) t
  