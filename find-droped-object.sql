
-- Find the current default trace file
DECLARE @tracefile NVARCHAR(260);
SELECT TOP (1) @tracefile = CONVERT(NVARCHAR(260), value)
FROM sys.fn_trace_getinfo(NULL)
WHERE property = 2;

-- Query for table drops
SELECT
    te.name                         AS event_name,
    t.DatabaseName,
    t.ObjectName                    AS table_name,
    t.HostName,
    t.ApplicationName,
    t.LoginName,
    t.SPID,
    t.StartTime                     AS drop_time
FROM ::fn_trace_gettable(@tracefile, DEFAULT) AS t
JOIN sys.trace_events AS te
  ON t.EventClass = te.trace_event_id
WHERE te.name IN ('Object:Deleted', 'Object:Drop')  -- DDL drops
  AND t.ObjectName = 'DailySAIDI'                -- <-- optional filter
  -- ObjectType codes commonly used for tables; include both to be safe:
  AND (t.ObjectType IN (8277, 8272) OR t.ObjectType IS NULL)
ORDER BY t.StartTime DESC;
