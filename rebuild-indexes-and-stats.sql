---------------------------------------------------------------------------------------------
-- dbcc reindex('dbo.ActiveSubscriptions', '', 80);
---------------------------------------------------------------------------------------------
select      'dbcc dbreindex (' + '''' + name + '''' + ',' + '''''' + ',' + '80);'
from        sys .tables
where       type_desc = 'user_table'
order by     Name

---------------------------------------------------------------------------------------------
-- alter index all on dbo.Table rebuild with (online = on, statistics_norecompute = on);
---------------------------------------------------------------------------------------------
select      'alter index all on dbo.' + name + ' rebuild with (online = off, statistics_norecompute = on)' + CHAR (10 ) + 'go' as Script
from        sys . tables
where       type_desc = 'user_table'
                                                           
-----------------------------------------------------------------------
-- update statistics dbo.ActiveSubscriptions
---------------------------------------------------------------------------------------------
select      'update statistics ' + name + ';'
from        sys .tables
where       type_desc = 'user_table'
order by     Name

---------------------------------------------------------------------------------------------
-- recompile procs
---------------------------------------------------------------------------------------------
select      'exec sp_recompile ' + '''' + name + ''''
from        sys .procedures ;
