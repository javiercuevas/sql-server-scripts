-----------------------------------------------------
-- lists the minute by minute breakdown of cpu
-- for the past 256 minutes
-----------------------------------------------------
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
    
DECLARE @ts_now BIGINT
--	2005 initiallly, 2008 MS drops the column cpu_ticks_in_ms cause of accuracy issues.
--         SELECT	@ts_now = cpu_ticks / CONVERT(FLOAT, cpu_ticks_in_ms)
-- 	FROM	sys.dm_os_sys_info

SELECT	@ts_now = cpu_ticks / (cpu_ticks/ms_ticks)
FROM	sys.dm_os_sys_info        

SELECT	record_id,
		CAST ( DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS SMALLDATETIME) AS EventTime, 
		SQLProcessUtilization,
		SystemIdle,
		100 - SystemIdle - SQLProcessUtilization AS OtherProcessUtilization
FROM	(
		SELECT 
				record.value('(./Record/@id)[1]', 'int') AS record_id,
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization,
				TIMESTAMP
		FROM (
				SELECT TIMESTAMP, CONVERT(XML, record) AS record 
				FROM sys.dm_os_ring_buffers 
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE '% %') AS x
		) AS y 
ORDER BY record_id DESC
    
END;


