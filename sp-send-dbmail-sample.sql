--------------------------------------------
--your eauto db
--------------------------------------------
use CEOJuice

------------------------------------------
--variables
--------------------------------------------
declare	@SQL varchar(max)
declare	@VarBody varchar(max)
declare	@RetCode int

---------------------------------------------
---just to check data before email
-- optional
-- create a unique global temp table name
---------------------------------------------
if object_id('tempdb..##GlobalTemp_123456') is not null
drop table ##GlobalTemp_123456

select	top 25 
		EquipmentNumber, 
		convert(varchar, CreateDate, 101) as CreateDate
into	##GlobalTemp_123456
from	SCEquipments

---------------------------------------------
---send only if condition is met
---------------------------------------------
if (select count(1) from ##GlobalTemp_123456) > 1
begin
	set		@VarBody = 'Your Report'
	set		@SQL = 
	'
	set nocount on
	select	* from ##GlobalTemp_123456
	'

	exec @RetCode = msdb.dbo.sp_send_dbmail
					@profile_name = 'Main',
					@from_address = 'noreply@ceojuice.com',
					@recipients = 'javier@ceojuice.com',
					@subject = 'My Equipment Report', 
					@body = @VarBody,
					@query = @SQL,
					@attach_query_result_as_file = 1,
					@query_result_separator = '	',
					@exclude_query_output = 1,
					@query_result_no_padding = 1,
					@query_result_header = 1,
					@query_attachment_filename = 'Equip.csv'
end

---------------------------------------------
---if error occured
---------------------------------------------
if @RetCode = 1
begin
	exec			msdb.dbo.sp_send_dbmail 
					@profile_name = 'Main',
					@from_address = 'noreply@ceojuice.com',
					@recipients = 'javier@ceojuice.com',
					@subject = 'My Equipment Report', 
					@body = 'An error occured sending sql email'
	raiserror('Error in sp_send_dbmail', 15, 1)
end

---------------------------------------------
---drops
---------------------------------------------
if object_id('tempdb..##GlobalTemp_123456') is not null
drop table ##GlobalTemp_123456