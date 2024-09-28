SELECT	T.session_id AS waiting_session_id ,
		DB_NAME(L.resource_database_id) AS DatabaseName ,
		T.wait_duration_ms / 60000. AS Duration_in_minutes ,
		T.waiting_task_address ,
		L.request_mode ,
		L.resource_type ,
		L.resource_associated_entity_id ,
		L.resource_description AS lock_resource_description ,
		T.wait_type ,
		T.blocking_session_id ,
		T.resource_description AS blocking_resource_description
FROM	sys.dm_os_waiting_tasks AS T
JOIN	sys.dm_tran_locks AS L ON T.resource_address = L.lock_owner_address
WHERE	T.wait_duration_ms > 1000
		AND T.session_id > 50;


/*

-------------------------------------------
-- resource_associated_entity_id
-------------------------------------------
SELECT	object_name(object_id) 'Table Name',
		object_id, 
		index_id, 
		row_count, 
		in_row_data_page_count, 
		lob_reserved_page_count
FROM	sys.dm_db_partition_stats
WHERE	partition_id = 72057733367332800

*/