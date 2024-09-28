-------------------------------------------
-- return list of dbs and their setting
-------------------------------------------
select name, is_read_committed_snapshot_on from sys.databases

-------------------------------------------
-- run after hours
-- as this disconnects users
-------------------------------------------
alter database Co???
set single_user
with rollback immediate
go
 
alter database Co???
set read_committed_snapshot on -- change on to off to undo
go
 
alter database Co???
set multi_user
go

