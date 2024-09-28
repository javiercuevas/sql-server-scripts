declare		@ViewID int



select		top 1 @ViewID = ViewID
from		LDViews (nolock)
where		DisplayName = 'IBPI Vendor Purchases'
order by	DisplayName

select		SQLSelect 
from		dbo.LdViewSQLSelectStmt (nolock)
where		ViewID = @ViewID

select		SQLFrom 
from		dbo.LdViewSQLFromStmt (nolock)
where		ViewID = @ViewID

select		FilterString
from		LdViewFilters (nolock)
where		ViewID = @ViewID



