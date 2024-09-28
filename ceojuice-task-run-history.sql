use CoreDB
go
--------------------------------------------------------------------
-- point to CEOJuice CoreDB and run to get task run history
--------------------------------------------------------------------

begin
set transaction isolation level read uncommitted

--------------------------------------------------------------------
declare    @RecordsPerTask int
set        @RecordsPerTask = 1

declare		@HourAdjust int
set			@HourAdjust = datediff(hour, sysutcdatetime(), getdate())
--------------------------------------------------------------------

select      *,
			row_number() over (partition by t.TaskID order by t.EventTimeStart desc) as RowNo
into        #EventLog
from		(
			select
						TaskID, 
						TaskInstanceID, 
						min(EventTime) as EventTimeStart,
						max(EventTime) as EventTimeEnd
			from        EventLog
			where       TaskInstanceID <> -1
			group by    TaskID, TaskInstanceID
			) t

--------------------------------------------------------------------
-- Last # of run times for each task and the runtime for the task
--------------------------------------------------------------------
select		row_number() over (partition by t.TaskName order by a.EventTimeStart desc) as TaskInstance,
            t.TaskName,
			a.TaskInstanceID,
            dateadd(hour, @HourAdjust, a.EventTimeStart) as TaskStartTime,
			dateadd(hour, @HourAdjust, a.EventTimeEnd) as TaskEndTime,
			dateadd(hour, @HourAdjust, b.EventTimeStart) as PreviousTaskStart,
            datediff(second, a.EventTimeStart, a.EventTimeEnd) as SecondsRunTime,
            datediff(minute, b.EventTimeStart, a.EventTimeStart) as MinutesSinceLastRun
from		dbo.Tasks t
cross apply	(select top (@RecordsPerTask) RowNo, TaskInstanceID, EventTimeStart, EventTimeEnd, TaskID from #EventLog where TaskID = t.TaskID order by EventTimeStart desc) a
left join	#EventLog b on b.TaskID = a.TaskID and b.RowNo = a.RowNo + 1 
order by    a.EventTimeStart desc, t.TaskName

--------------------
-- clean up
--------------------

drop table #EventLog

end




