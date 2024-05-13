-- Alejandro Report
with OracleDbInvestigatorsWithStudies as (select *
                                          from openquery(ONCOREPROD, ' select distinct r.protocol_no, r.staff_name
from UACC_ONCORE_RW_UTILS.SV_PCL_STAFF_RO r
         join UACC_ONCORE_RW_UTILS.PROTOCOLS p
              on p.PROTOCOL_NO = r.PROTOCOL_NO
where
Department_Name = ''COM Tucson''
--   and lower(STAFF_ROLE) != ''Principal Investigator''
  and (
    lower(r.STAFF_ROLE) like ''% pi %''
        or lower(r.STAFF_ROLE) like ''%-pi %''
        or lower(r.STAFF_ROLE) like ''% investig%''
        or lower(r.STAFF_ROLE) like ''%-investig%''
    )'
                                               ))
   , TotalNumberOfDeptsUnderCOMT as (select count(distinct pi.DEPT) DeptCount
                                     from OnCoreDW.dw.DimPI pi
                                              inner join OnCoreDW.dw.FactProtocols p on pi.surrKey = p.PI_Key
                                         and p.PI_Key != -1
                                         and p.Department_Name = 'COM Tucson'
                                         and pi.College = 'College of Medicine - Tucson')
   , ClosedStudiesWithInProcessSubjects as (select distinct p.protocol_no
                                            from Protocols p
                                                     inner join Enrollments e on e.Protocol_No = p.protocol_no
                                            where [OnStudy?] = 'T'
                                              and lower(p.Current_Status) like '%clos%'
--                                               and p.Library = 'General Medicine'
                                              and Department_Name = 'COM Tucson')

select 'Studies Phase' as Metric,
       'Open'          as Legend,
       count(*)        as Measure
from protocols p
         join ProtocolStatus ps on p.Current_Status = ps.current_status
where
--     Library = 'General Medicine'
-- and
    Department_Name = 'COM Tucson'
  and (ps.Phase = 'Open'
    or exists(select 1 from ClosedStudiesWithInProcessSubjects c where c.protocol_no = p.protocol_no))

union

select 'Studies Phase' as Metric,
       'Activation'    as Legend,
       count(*)        as Measure
from protocols p
         join ProtocolStatus ps on p.Current_Status = ps.current_status
where
  --     Library = 'General Medicine'
-- and
    Department_Name = 'COM Tucson'
  and ps.Phase = 'Activation'

union

select 'IIT'                                               as Metric,
       case iit when 'N' then 'No' when 'Y' then 'Yes' end as Legend,
       count(*)                                            as Measure
from protocols p
         inner join ProtocolStatus ps on ps.current_status = p.Current_Status
where
  --     Library = 'General Medicine'
-- and
    Department_Name = 'COM Tucson'
  and (ps.Phase = 'Open'
    or exists(select 1 from ClosedStudiesWithInProcessSubjects c where c.protocol_no = p.protocol_no))
group by iit

union

select 'Sponsor Type' as Metric,
       Sponsor_Type   as Legend,
       count(*)       as Measure
from protocols p
         inner join ProtocolStatus ps on ps.current_status = p.Current_Status
where
  --     Library = 'General Medicine'
-- and
    Department_Name = 'COM Tucson'
  and (ps.Phase = 'Open'
    or exists(select 1 from ClosedStudiesWithInProcessSubjects c where c.protocol_no = p.protocol_no))
group by Sponsor_Type

-- select protocol_no from Protocols where Sponsor_Type is null and Library = 'General Medicine'
union

select 'All Serving PIs'         as Metric,
       ''                        as Legend,
       count(distinct p.pi_name) as Measure
from Protocols p
where
    --     Library = 'General Medicine'
-- and
    Department_Name = 'COM Tucson'

union

select 'All Serving Investigators' as Metric,
       ''                          as Legend,
       count(distinct staff_name)  as Measure
from OracleDbInvestigatorsWithStudies p

union

select 'Open/Activation Serving PIs' as Metric,
       ''                            as Legend,
       count(distinct p.pi_name)     as Measure
from Protocols p
         inner join ProtocolStatus ps on ps.current_status = p.Current_Status
where
  --     Library = 'General Medicine'
-- and
    p.Department_Name = 'COM Tucson'
  and (ps.Phase in ('Open', 'Activation')
    or exists(select 1 from ClosedStudiesWithInProcessSubjects c where c.protocol_no = p.protocol_no))

union

select 'Open/Activation Serving Investigators' as Metric,
       ''                                      as Legend,
       count(distinct o.staff_name)            as Measure
from OracleDbInvestigatorsWithStudies o
         inner join Protocols p on p.protocol_no = o.protocol_no
         inner join ProtocolStatus ps on ps.current_status = p.Current_Status
where (ps.Phase in ('Open', 'Activation')
    or exists(select 1 from ClosedStudiesWithInProcessSubjects c where c.protocol_no = p.protocol_no))

union

select distinct 'Departments' as Metric,
                ''            as Legend,
                DeptCount     as Measure
from TotalNumberOfDeptsUnderCOMT


union

select 'Accruals in 2023'         as Metric,
       ''                         as Legend,
       sum(e.NumberOfEnrollments) as Measure
from protocols p
         join Enrollments e on e.Protocol_No = p.protocol_no and year(e.On_StudyDate) = 2023
where
--     Library = 'General Medicine'
-- and
Department_Name = 'COM Tucson'