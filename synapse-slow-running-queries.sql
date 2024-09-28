SELECT      TOP 100
            *
FROM        sys.dm_pdw_exec_requests
WHERE        end_time >= DATEADD(MINUTE, -30, CURRENT_TIMESTAMP)
ORDER BY    total_elapsed_time DESC