BEGIN TRAN
update table_a set ID=ID where ID = 100;
On two run

BEGIN TRAN
update table_b set ID=ID where ID =100;

--Then, copy the update statements to the opposing sessions and run at the same time. In one,

update table_b set ID=ID where ID =100;
--In two

update table_a set ID=ID where ID = 100;