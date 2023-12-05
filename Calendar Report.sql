
use OnCoreStaging
go
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
dbo.BusinessDaysDuration(l1.New_Date, l1.Released_Date) as Total_Duration
 from level1 as l1


-- SELECT
--     protocol_id,
--     protocol_no,
--     version_no,
--     len(status),
--     strikethrough,
--     len(created_user),
--     created_date
-- FROM
--     ONCOREPROD..UACC_ONCORE_PROD.SV_STUDY_SPEC_STATUS_HISTORY
-- WHERE PROTOCOL_NO IN ('2009015316', --SUSIE FIRST
--                           '2005630160', -- WENDY
--                           '2102537612')
-- --SUSIE SECOND
-- ORDER BY PROTOCOL_NO, CREATED_DATE;

-- select *
-- from
--     (
-- select s.*,
--         case when status = 'New' then 1
--      when status = 'Completed' then 2
--      when status = 'Coordinator Signoff' then 3
--      when status = 'Released' then 4
--      else 0
-- end rankStatus,

--         case when strikethrough = 'N' then 
--    case when status = 'New' then 1
--      when status = 'Completed' then 2
--      when status = 'Coordinator Signoff' then 3
--      when status = 'Released' then 4
--      else 0
-- end 
-- else 0
-- end rankStatus2

--     --select * 
--     from uacc_oncore_prod.sv_study_spec_status_history s
--     WHERE PROTOCOL_NO IN ('2009015316', --SUSIE FIRST
--                           '2005630160', -- WENDY
--                           '2102537612')
--     --SUSIE SECOND
--     order by protocol_id,rankstatus2,created_date
-- )xx
-- ;

-- with
--     rws
--     as
--     (
--         select s.*, row_number() over (
--         partition by protocol_id
--         order by version_no desc,
--             case when strikethrough = 'N' then 
--                 case when status = 'New' then 1
--                     when status = 'Completed' then 2
--                     when status = 'Coordinator Signoff' then 3
--                     when status = 'Released' then 4
--                 else 0
--                 end 
--             else 0
--             end desc, created_date desc
--             )rn

--         from uacc_oncore_prod.sv_study_spec_status_history s
--         WHERE PROTOCOL_NO IN ('2009015316', --SUSIE FIRST
--                           '2005630160', -- WENDY
--                           '2102537612', --SUSIE SECOND
--                           '1609876907') -- 41 records
--             and version_no = 1
--     )
-- select *
-- from rws
-- where rn = 1
-- order by protocol_no, version_no,created_date desc
-- ;
--=======

