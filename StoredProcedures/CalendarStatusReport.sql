SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[CalendarStatusReport]
@FromDate date = null,
@ToDate date = null
as 
begin
with Level1 as (

select ch.protocol_no,
max(case lower([status]) when 'new' then ch.created_date end) as New_Date,
max(case lower([status]) when 'completed' then ch.created_date end) as Completed_Date,
max(case lower([status]) when 'released' then ch.created_date end) as Released_Date

 from [dbo].[ProtocolCalendarStatusHistory] ch
inner join protocols p on p.protocol_id = ch.protocol_id
where p.Library in ('Oncology', 'General Medicine') 
and ch.strikethrough = 'N'
and ch.version_no = 1 
group by ch.protocol_no
)
select
 l1.protocol_no,
 l1.New_Date,
 dbo.BusinessDaysDuration(l1.New_Date, l1.Completed_Date) as New_To_Completed_Duration,
 l1.Completed_Date,
 dbo.BusinessDaysDuration(l1.Completed_Date, l1.Released_Date) as Completed_To_Released_Duration,
 l1.Released_Date,
dbo.BusinessDaysDuration(l1.New_Date, l1.Released_Date) as New_To_Released_Duration
 from level1 as l1
 where (@FromDate is null or New_Date >= @FromDate)
 and (@ToDate is null or New_Date <= @ToDate)
end;
GO
