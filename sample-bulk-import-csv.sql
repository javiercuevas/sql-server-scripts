use Test
go

if object_id('ImportedKMBS') is not null
drop table ImportedKMBS
go

create table ImportedKMBS
(
InvoiceNo   varchar(100),
InvoiceDate date,
RefNo       varchar(100),
DocType     varchar(100),
NetDueDate  date,
DaysArr     varchar(100),
Terms       varchar(100),
Amount      money
)

bulk insert ImportedKMBS
from 'C:\Users\admin\Desktop\KMBS_Balance_1196566_20170113143025.csv'
with 
(
    FieldTerminator = ',',
    RowTerminator   = '\n',
    FirstRow        = 2
)
go

select  *
from    ImportedKMBS

