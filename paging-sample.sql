declare	@PageIndex int = 1
declare	@PageSize int = 50

select	count(1) over() as TotalRows,
		EquipmentID, 
		EquipmentNumber
from	SCEquipments
order by	EquipmentID


offset (@PageIndex - 1) * @PageSize rows

fetch next @PageSize rows only;