select  object_name(st.object_id) as table_name, 
		ix.name as index_name,
		st.* 
from	sys.dm_db_index_operational_stats (db_id(db_name()), null, null, null) st
left join	sys.indexes ix on ix.object_id = st.object_id and ix.index_id = st.index_id
where	object_name(st.object_id)  = 'SCCalls'
order by	st.row_lock_wait_in_ms desc