WITH dtu_vcore_map AS
(
SELECT rg.slo_name,
       CAST(DATABASEPROPERTYEX(DB_NAME(), 'Edition') AS nvarchar(40)) COLLATE DATABASE_DEFAULT AS dtu_service_tier,
       CASE WHEN slo.slo_name LIKE '%SQLG4%' THEN 'Gen4'
            WHEN slo.slo_name LIKE '%SQLGZ%' THEN 'Gen4'
            WHEN slo.slo_name LIKE '%SQLG5%' THEN 'Gen5'
            WHEN slo.slo_name LIKE '%SQLG6%' THEN 'Gen5'
            WHEN slo.slo_name LIKE '%SQLG7%' THEN 'Gen5'
            WHEN slo.slo_name LIKE '%GPGEN8%' THEN 'Gen5'
       END COLLATE DATABASE_DEFAULT AS dtu_hardware_gen,
       s.scheduler_count * CAST(rg.instance_cap_cpu/100. AS decimal(3,2)) AS dtu_logical_cpus,
       CAST((jo.process_memory_limit_mb / s.scheduler_count) / 1024. AS decimal(4,2)) AS dtu_memory_per_core_gb
FROM sys.dm_user_db_resource_governance AS rg
CROSS JOIN (SELECT COUNT(1) AS scheduler_count FROM sys.dm_os_schedulers WHERE status COLLATE DATABASE_DEFAULT = 'VISIBLE ONLINE') AS s
CROSS JOIN sys.dm_os_job_object AS jo
CROSS APPLY (
            SELECT UPPER(rg.slo_name) COLLATE DATABASE_DEFAULT AS slo_name
            ) slo
WHERE rg.dtu_limit > 0
      AND
      DB_NAME() COLLATE DATABASE_DEFAULT <> 'master'
      AND
      rg.database_id = DB_ID()
)
SELECT dtu_logical_cpus,
       dtu_hardware_gen,
       dtu_memory_per_core_gb,
       dtu_service_tier,
       CASE WHEN dtu_service_tier = 'Basic' THEN 'General Purpose'
            WHEN dtu_service_tier = 'Standard' THEN 'General Purpose or Hyperscale'
            WHEN dtu_service_tier = 'Premium' THEN 'Business Critical or Hyperscale'
       END AS vcore_service_tier,
       CASE WHEN dtu_hardware_gen = 'Gen4' THEN dtu_logical_cpus
            WHEN dtu_hardware_gen = 'Gen5' THEN dtu_logical_cpus * 0.7
       END AS Gen4_vcores,
       7 AS Gen4_memory_per_core_gb,
       CASE WHEN dtu_hardware_gen = 'Gen4' THEN dtu_logical_cpus * 1.7
            WHEN dtu_hardware_gen = 'Gen5' THEN dtu_logical_cpus
       END AS Gen5_vcores,
       5.05 AS Gen5_memory_per_core_gb,
       CASE WHEN dtu_hardware_gen = 'Gen4' THEN dtu_logical_cpus
            WHEN dtu_hardware_gen = 'Gen5' THEN dtu_logical_cpus * 0.8
       END AS Fsv2_vcores,
       1.89 AS Fsv2_memory_per_core_gb,
       CASE WHEN dtu_hardware_gen = 'Gen4' THEN dtu_logical_cpus * 1.4
            WHEN dtu_hardware_gen = 'Gen5' THEN dtu_logical_cpus * 0.9
       END AS M_vcores,
       29.4 AS M_memory_per_core_gb
FROM dtu_vcore_map;