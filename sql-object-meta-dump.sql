set nocount on

declare	@OutputChoice		nvarchar(100) = 'tables' -- schemas, tables, views, procs, functions, triggers

declare @ObjectSchema		nvarchar(255)
declare @ObjectName			nvarchar(255)
declare @ObjectDefinition	nvarchar(max)
declare @ObjectTypeDetail	nvarchar(255)

declare @RowNumber      int = 1
declare @TotalRows		int = 0

-------------------------
-- table of objects
-------------------------
declare	@ObjectsTable table
(
	ObjectSchema		nvarchar(255),
	ObjectName			nvarchar(255),
	ObjectDefinition	nvarchar(max),
	ObjectTypeDetail	nvarchar(255)
)

if @OutputChoice = 'views'
begin
	insert into @ObjectsTable
    select		schema_name(schema_id) as ObjectSchema, name as ObjectName,  object_definition(v.object_id) as ObjectDefinition, '' as ObjectTypeDetail
    from		sys.views v
    inner join	sys.sql_modules m ON v.object_id = m.object_id
end
if @OutputChoice = 'procs'
begin
	insert into @ObjectsTable
    select		schema_name(schema_id) as ObjectSchema, name as ObjectName, definition as ObjectDefinition, '' as ObjectTypeDetail
    from		sys.procedures p
    inner join	sys.sql_modules m ON p.object_id = m.object_id
end
if @OutputChoice = 'functions'
begin
	insert into @ObjectsTable
    select		schema_name(schema_id) as ObjectSchema, name as ObjectName,  object_definition(o.object_id) as ObjectDefinition, o.type_desc as ObjectTypeDetail
    from		sys.objects o
    inner join	sys.sql_modules m ON o.object_id = m.object_id
	where		1=1
				and type_desc like '%function%'
end
if @OutputChoice = 'triggers'
begin
	insert into @ObjectsTable
    select		schema_name(schema_id) as ObjectSchema, name as ObjectName,  object_definition(o.object_id) as ObjectDefinition, o.type_desc as ObjectTypeDetail
    from		sys.objects o
    inner join	sys.sql_modules m ON o.object_id = m.object_id
	where		1=1
				and type_desc like '%trigger%'
end
if @OutputChoice = 'schemas'
begin
	insert into @ObjectsTable
 	select		'', name as ObjectName, '', ''
	from		sys.schemas s
	where		principal_id = 1
	order by	1
end
if @OutputChoice = 'tables'
begin
	with RowCountCTE AS
	(
		select TableSchemaID = s.schema_id,
		s.name as schema_name,
		t.name as table_name,
		p.rows as row_count
		from sys.tables t
		inner join sys.schemas s on t.schema_id = s.schema_id
		inner join sys.indexes i on t.object_id = i.object_id
		inner join sys.partitions p on i.object_id = p.object_id and i.index_id = p.index_id
		where t.is_ms_shipped = 0
		--and s.name in ('attribution')
		group by s.schema_id, s.Name, t.name, p.Rows

	),
	DetailCTE AS
	(
		select distinct
		schema_name = schema_name(sysobjects.uid),
		table_name = sysobjects.name,
		column_name = syscolumns.name,
		datatype = systypes.name,
		length = syscolumns.length,
		datatype_and_length =
		case
		when systypes.name like '%nvarchar%' and syscolumns.length in (0, -1) then systypes.name + ' (max)'
		when systypes.name like '%nvarchar%' then systypes.name + ' (' + cast(syscolumns.length / 2 as varchar) + ')'
		when systypes.name like '%char%' then systypes.name + ' (' + cast(syscolumns.length as varchar) + ')'
		else systypes.name
		end,
		colorder = syscolumns.colorder
		from sysobjects
		inner join syscolumns on sysobjects.id = syscolumns.id
		inner join systypes on syscolumns.xtype = systypes.xtype
		where sysobjects.xtype = 'U'
		and systypes.name <> 'sysname'
	)
	----------------------------
	--insert
	----------------------------
	insert into @ObjectsTable
	select	d.schema_name,
			d.table_name,
			stuff((
							select ', ' + char(10) + cast(column_name as varchar(100)) + ' ' + '[' + cast(datatype_and_length as varchar(100)) + ']'
							from DetailCTE 
							where schema_name = d.schema_name and table_name = d.table_name
							group by colorder, column_name, datatype_and_length
							order by colorder
							for xml path('') 
							),1,1,''
						)  as column_name,
			'rows: ' + cast(r.row_count as varchar) AS ObjectTypeDetail
	from	DetailCTE d
	left join	RowCountCTE r on r.schema_name = d.schema_name and r.table_name = d.table_name
	group by d.schema_name, d.table_name, r.row_count
	order by d.schema_name, d.table_name
end


-------------------------
-- rows
-------------------------
set @TotalRows = (select count(1) from @ObjectsTable)

-------------------------
-- define cursor
-------------------------
declare myCursor

cursor	for

select		ObjectSchema, 
			ObjectName, 
			ObjectDefinition,
			ObjectTypeDetail
from		@ObjectsTable
where       1=1
order by	1, 2


-------------------------
-- loop
-------------------------
print	'Date Created: ' + convert(varchar, current_timestamp, 102)
print	'Total Items: ' + cast(@TotalRows as varchar)
print	'Database: ' + db_name()
print	'Type: ' + @OutputChoice
print	''

open myCursor
	fetch next
	from myCursor 
	into	@ObjectSchema,
			@ObjectName,
			@ObjectDefinition,
			@ObjectTypeDetail
					
	while @@fetch_status = 0
		begin
		print	'-------------------------------------------------------------------------------------------------------------'
        print   cast(@RowNumber as varchar) + '.' + ' ' + @ObjectSchema + '.' + @ObjectName + ' ' + 
					case when @ObjectTypeDetail = '' THEN '' ELSE concat('(', lower(@ObjectTypeDetail), ')') END
		print	'-------------------------------------------------------------------------------------------------------------'
		print	@ObjectDefinition
		print	''
		
		fetch	next
		from	myCursor 
		into	@ObjectSchema,
				@ObjectName,
				@ObjectDefinition,
				@ObjectTypeDetail

        set @RowNumber = @RowNumber + 1
	end
    
close myCursor

deallocate myCursor


