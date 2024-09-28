declare	@ViewID			int
declare @DisplayName	varchar(255)
declare @Description	varchar(255)
declare	@CreatorID		varchar(255)
declare	@CreateDate		datetime
declare	@UpdatorID		varchar(255)
declare	@LastUpdate		datetime
declare	@SQLSelect		varchar(max)
declare	@SQLFrom		varchar(max)
declare	@SQLFilters		varchar(max)
declare @RowNumber      int
set     @RowNumber = 1

declare myCursor

cursor	for
select		
			vw.ViewID,
			vw.DisplayName,
			vw.Description,
			vw.CreatorID,
			vw.CreateDate,
			vw.UpdatorID,
			vw.LastUpdate,
			se.SQLSelect,
			fr.SQLFrom,
			(
				select	cast(FilterName as varchar(max)) + ' : ' + cast(FilterString as varchar(max)) + char(10)
				from	dbo.LdViewFilters
				where	ViewID = vw.ViewID
				for xml path (''), TYPE).value('.','nvarchar(max)'
			) as Filters
from		dbo.LDViews vw with (nolock)
join		dbo.LdViewSQLSelectStmt se with (nolock) on se.ViewID = vw.ViewID
join		dbo.LdViewSQLFromStmt fr with (nolock) on fr.ViewID = vw.ViewID
order by	DisplayName

-------------------------
-- loop over eviews
-------------------------
open myCursor
	fetch next
	from myCursor 
	into	@ViewID,
			@DisplayName, 
			@Description,
			@CreatorID,
			@CreateDate,
			@UpdatorID,
			@LastUpdate,
			@SQLSelect,
			@SQLFrom,
			@SQLFilters
					
	while @@fetch_status = 0
		begin
		print	'---------------------------------------------------------------------------------------------------'
        print   cast(@RowNumber as varchar) + '.'
		print	'Display Name:  ' + @DisplayName
		print	'Description: ' + @Description
		print	'ViewID: ' + cast(@ViewID as varchar)
		print	'CreatorID: ' + @CreatorID
		print	'Create Date: ' + convert(char(10), @CreateDate, 101)
		print	'UpdatorID: ' + @UpdatorID
		print	'Last Update: ' + convert(char(10), @LastUpdate, 101)
		print	'---------------------------------------------------------------------------------------------------'
		print	@SQLSelect + @SQLFrom
		print	'---------------------------------------------------------------------------------------------------'
		print   'Filters:'
		print   @SQLFilters
		
		fetch	next
		from	myCursor 
		into	@ViewID,
				@DisplayName,
				@Description,
				@CreatorID,
				@CreateDate,
				@UpdatorID,
				@LastUpdate,
				@SQLSelect,
				@SQLFrom,
				@SQLFilters

        set @RowNumber = @RowNumber + 1
	end
    
close myCursor

deallocate myCursor







