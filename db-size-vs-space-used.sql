SELECT
    DB.name,
    MF.physical_name,
    MF.type_desc AS FileType,
    MF.size * 8 / 1024 AS FileSizeMB,
    fileproperty(MF.name, 'SpaceUsed') * 8/ 1024 AS UsedSpaceMB,
    mf.name LogicalName
FROM
    sys.master_files MF
    JOIN sys.databases DB ON DB.database_id = MF.database_id
WHERE   DB.name = 'yourdatabasename'