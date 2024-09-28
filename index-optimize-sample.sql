EXECUTE dbo.IndexOptimize
@Databases = 'DBName',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 50,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@LogToTable = 'N',
@Indexes = 'ALL_INDEXES';

