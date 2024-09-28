-- this is just a sample so of course all the records
-- will insert to our temp table since it's empty...
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/merge-transact-sql

create	table #vt_CoveragePeriods (EquipmentID int, Period int)


MERGE #vt_CoveragePeriods AS target  
USING 
(
	select	distinct 
			EquipmentID, Period
	from	dbo.ardCustTransDetails ard
	where	ard.contractid is null
			and EquipmentID is not null
) AS source 
ON (target.EquipmentID = source.EquipmentID and target.Period = source.Period)  
--WHEN MATCHED THEN 
	--DO AN UPDATE  
WHEN NOT MATCHED THEN  
	INSERT (EquipmentID, Period)  
	VALUES (source.EquipmentID, source.Period); 

--OUTPUT deleted.*, $action, inserted.* INTO #MyTempTable;  


select	*
from	#vt_CoveragePeriods
order by 1, 2

drop table #vt_CoveragePeriods