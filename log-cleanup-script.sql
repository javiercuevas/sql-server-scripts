/*

select	EventOutputID, count(1)
from	ZCJ_EventTransactionLog with (nolock)
group by EventOutputID
order by 2 desc

select	top 10 *
from	ZCJ_EventTransactionLog
where	EventOutputID = 268
order by TriggerDate

*/

declare @CutOffDate datetime 
declare	@EventOutputID int 

set	@EventOutputID = 268
set @CutOffDate = '1/1/2019'

declare @IdsToDelete table (TransactionID int) 

declare @RowsDeleted int 
set		@RowsDeleted = 1

while @RowsDeleted > 0
begin
	begin tran
	
	--list of ids to delete
	insert into @IdsToDelete
	select top 5000 TransactionID
	from	ZCJ_EventTransactionLog
	where	1=1
			and EventOutputID = @EventOutputID
			and TriggerDate < @CutOffDate

	--delete
	delete from zcj_eventtransactionlog
	where	TransactionID in (select Transactionid from @IdsToDelete)
	
	--reset
	delete from @IdsToDelete
	
	--records deleted in last batch
	set @RowsDeleted = @@ROWCOUNT
	
	commit
end