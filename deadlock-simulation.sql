------------------------
--tab 1
------------------------

-- 1.
BEGIN TRAN
update table_a set ID=ID where ID = 100;

-- 3.
update table_b set ID=ID where ID =100;


------------------------
-- tab 2
------------------------

-- 2.
BEGIN TRAN
update table_b set ID=ID where ID =100;

-- 4.
update table_a set ID=ID where ID = 100;