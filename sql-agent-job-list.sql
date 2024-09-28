SELECT 
 job_id
,name
,enabled
,date_created
,date_modified
,'exec sp_delete_job ' + cast(job_id as varchar(100)) + ';'
FROM msdb.dbo.sysjobs
WHERE enabled = 0
ORDER BY date_created