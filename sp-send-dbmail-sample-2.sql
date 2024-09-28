declare @tab char(1) = char(9)
declare	@SQL varchar(max)
declare	@VarBody varchar(max)

set		@VarBody = 'Your Report'

set		@SQL = 

'
SET NOCOUNT ON

SELECT 
 ac.ActivityCodeID,
 ActivityCode = ac.ActivityCode,
 ActivityCodeDesc = ac.Description,
 ActivityCodeCategory = acc.ActivityCodeCategory,
 ActivityCodeCategoryDesc = acc.Description,
 Active = ac.Active,
 Billable = acc.Billable,
 PaidTime = acc.PaidTime,
 ExportCode = acc.PRExportCode 
 
FROM CoAtlanta.dbo.PRActivityCodes ac
  INNER JOIN CoAtlanta.dbo.PRActivityCodeCategories acc ON acc.ActivityCodeCategoryID = ac.ActivityCodeCategoryID
'


EXEC msdb.dbo.sp_send_dbmail
              @profile_name = 'Main',
              @from_address = 'javier@ceojuice.com',
              @recipients = 'javier.cuevas.asu@gmail.com',
              @body = @varBody,
              --@body_format = 'HTML',
              @query = @SQL,
              @attach_query_result_as_file = 1,
              @query_result_separator = @tab,
              @exclude_query_output = 1,
              @query_result_no_padding = 1,
              @query_result_header = 1,
			  --@query_result_width = 50,
              @query_attachment_filename = 'MyTest.csv'