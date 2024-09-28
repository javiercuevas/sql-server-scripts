-------------------
--views
-------------------
/*
select	v.name, 'drop view ' + '_custom_placeholder.' + v.name as drop_script
from	sys.views v
join	sys.schemas s on s.schema_id = v.schema_id
where	1=1
		and s.name = '_custom_placeholder'
*/


-------------------
--functions
-------------------
/*
select	o.name, 'drop function ' + '_custom_placeholder.' + o.name as drop_script
from	sys.objects o
join	sys.schemas s on s.schema_id = o.schema_id
where	1=1
		and type in ('FN', 'IF', 'TF')  -- scalar, inline table-valued, table-valued
		and s.name = '_custom_placeholder'
*/


------------------
-- procs
------------------
/*
select	p.name, 'drop procedure ' + '_custom_placeholder.' + p.name as drop_script
from	sys.procedures p
join	sys.schemas s on s.schema_id = p.schema_id
where	1=1
		and s.name = '_custom_placeholder%'
*/


