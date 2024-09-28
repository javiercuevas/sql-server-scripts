DECLARE @ctr bigint
SELECT @ctr = cntr_value
    FROM sys.dm_os_performance_counters 
    WHERE counter_name = 'transactions/sec' 
        AND object_name = 'SQLServer:Databases' 
        AND instance_name = 'CoreDB'
WAITFOR DELAY '00:00:10'
SELECT cntr_value - @ctr 
    FROM sys.dm_os_performance_counters 
    WHERE counter_name = 'transactions/sec' 
        AND object_name = 'SQLServer:Databases' 
        AND instance_name = 'CoreDB'