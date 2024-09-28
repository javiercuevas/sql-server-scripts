------------------------------------------------------------------
-- returns info on all the database files on the sql instance
------------------------------------------------------------------
select database_id,
       convert(varchar(25), DB.name) as dbName,
       convert(varchar(10), databasepropertyex(name, 'status')) as [Status],
       state_desc,
       (select count(1)
        from   sys.master_files
        where  db_name(database_id) = DB.name
               and type_desc = 'rows') as DataFiles,
       (select sum((size * 8) / 1024)
        from   sys.master_files
        where  db_name(database_id) = DB.name
               and type_desc = 'rows') as [Data MB],
       (select count(1)
        from   sys.master_files
        where  db_name(database_id) = DB.name
               and type_desc = 'log') as LogFiles,
       (select sum((size * 8) / 1024)
        from   sys.master_files
        where  db_name(database_id) = DB.name
               and type_desc = 'log') as [Log MB],
       user_access_desc as [User access],
       recovery_model_desc as [Recovery model],
       case compatibility_level
           when 60 then '60 (SQL Server 6.0)'
           when 65 then '65 (SQL Server 6.5)'
           when 70 then '70 (SQL Server 7.0)'
           when 80 then '80 (SQL Server 2000)'
           when 90 then '90 (SQL Server 2005)'
           when 100 then '100 (SQL Server 2008)'
           when 110 then '110 (SQL Server 2012)'
           when 120 then '120 (SQL Server 2014)'
           when 130 then '130 (SQL Server 2016)'
		   when 140 then '140 (SQL Server 2017)'
		   when 150 then '150 (SQL Server 2019)'
       end as [compatibility level],
       convert(varchar(20), create_date, 103) + ' '
       + convert(varchar(20), create_date, 108) as [Creation date],
       -- last backup
       isnull((select top 1 case TYPE
                                when 'D' then 'Full'
                                when 'I' then 'Differential'
                                when 'L' then 'Transaction log'
                            end
                            + ' – '
                            + ltrim(isnull(str(abs(datediff(DAY, getdate(), Backup_finish_date))) + ' days ago', 'NEVER'))
                            + ' – '
                            + convert(varchar(20), backup_start_date, 103)
                            + ' '
                            + convert(varchar(20), backup_start_date, 108)
                            + ' – '
                            + convert(varchar(20), backup_finish_date, 103)
                            + ' '
                            + convert(varchar(20), backup_finish_date, 108)
                            + ' ('
                            + cast(datediff(second, BK.backup_start_date, BK.backup_finish_date) as varchar(4))
                            + ' ' + 'seconds)'
               from   msdb..backupset BK
               where  BK.database_name = DB.name
               order  by backup_set_id desc), '-') as [Last backup],
       case
           when is_fulltext_enabled = 1 then 'Fulltext enabled'
           else ''
       end as [fulltext],
       case
           when is_auto_close_on = 1 then 'autoclose'
           else ''
       end as [autoclose],
       page_verify_option_desc as [page verify option],
       case
           when is_read_only = 1 then 'read only'
           else ''
       end as [read only],
       case
           when is_auto_shrink_on = 1 then 'autoshrink'
           else ''
       end as [autoshrink],
       case
           when is_auto_create_stats_on = 1 then 'auto create statistics'
           else ''
       end as [auto create statistics],
       case
           when is_auto_update_stats_on = 1 then 'auto update statistics'
           else ''
       end as [auto update statistics],
       case
           when is_in_standby = 1 then 'standby'
           else ''
       end as [standby],
       case
           when is_cleanly_shutdown = 1 then 'cleanly shutdown'
           else ''
       end as [cleanly shutdown]
from   sys.databases DB
order  by dbName,
          [Last backup] desc,
          name 
