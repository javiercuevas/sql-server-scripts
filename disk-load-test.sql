use master
go

if object_id('_LoadTest') is null
begin

    CREATE TABLE [dbo].[_LoadTest](
	    [ID] [int] IDENTITY(1,1) NOT NULL,
	    [Name] [varchar](50) NULL,
     CONSTRAINT [PK_LoadTest] PRIMARY KEY CLUSTERED 
    (
	    [ID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]

end



declare @Loop int = 1

while @Loop <= 1000
begin

	insert into _LoadTest
	values ( @loop )

	set @Loop = @Loop + 1

end

select *
from	_LoadTest


drop table _LoadTest