-- select * from [dbo].[Funding Tooltip]
select *
from [dbo].[Offices]
select *
from [dbo].[Proposals]
select *
from [dbo].[Proposals]
where [Lead Investigator Id] = '22060596'
select distinct [Proposal ID], [Investigator Name]
from [dbo].[Proposals]
order by [Proposal ID]
select *
from [dbo].[Research]

select *
from [Room Classification]
where
-- [Person Name] = '-'
-- and
[Room ID] = '0501'

--  

select
    [College Name],
    [Building Name],
    [Space Department Name],
    rc.[Floor ID],
    sum(Administration) as Administration,
    sum(Education) as Education,
    sum(Research) as Research,
    sum([None]) as [None]

-- , [Room Classification]
from [dbo].[Room Classification] rc
--  where 
--  rc.[Person Name] != '-'
--  rc.[Person Name] = 'Parthasarathy,Sairam'

order by rc.[Fiscal Year] desc
-- SF
-- select * from [dbo].[Space Tooltip]

------------- MTDC SUMMARY

-- with
--     a
--     as
    
--     (
        select
            sf.[Fiscal Year] ,
            sf.[College Name] ,
            sf.[Organization-Name] as Dept ,
            sf.[Investigator Name] ,
            sf.[Investigator Id] ,
            format(round(sum(sf.[MTDC Base]),0),'N0') MTDC,
            format(round(sum(sf.[Total Expenses]),0),'N0') Expenditures,
            format(round(sum(sf.[Area by PI]),0),'N0') [Research Area],
            -- round(sum(sf.[Area by PI]),0) [Research Area],
            format(round(sum(sf.[Total Obligated Amount]),0),'N0') Obligated,
            case when sum(sf.[Area by PI]) != 0 and [Fiscal Year] = 2024 
            then format(round(sum(PI_Metric_1.PI_AVG_MTDC)/sum(sf.[Area by PI]),2),'N0') end as [Current $/SqFt],
                case when [Fiscal Year] != year(GETDATE()) 
                then format(round( sum([MTDC Base])/ 3 / 199 ,0),'N0') end as [Qualifying SqFt]
--             case when [Fiscal Year] != year(GETDATE()) 
-- then sum([MTDC Base]) /3 /199 end as [Qualifying SqFt]

        from SpaceFunding sf
        outer apply (select sum(sf_inner.[MTDC Base])/3 as PI_AVG_MTDC
            from SpaceFunding sf_inner
            where sf_inner.[Fiscal Year] in ('2021','2022','2023') and
                -- [Organization-Name] = 'Pharmacology and Toxicology' and
                [Investigator Name] != '-' and
                sf_inner.[Investigator Id] = sf.[Investigator Id]) as PI_Metric_1
        where 
-- lower([Organization-Name]) like '%pedia%'
-- [Organization-Name] = 'Pharmacy Administration'
--     and
    -- sf.[Organization-Name] = 'Epidemiology and Biostatistics' and
    [Investigator Name] != '-'
        group by sf.[Investigator Id], sf.[Investigator Name], sf.[Organization-Name], sf.[College Name] , sf.[Fiscal Year]
        order by [Fiscal Year]desc, [Organization-Name]
--     )
-- select
--     round(sum(a.[Qualifying SqFt]),0) as [Qualifying SqFt],
--     (select sum(a1.[Research Area])
--     from a as a1
--     where a1.[Fiscal Year] = 2024) as [Research Area 2024],
--     sum(a.[Qualifying SqFt]) - (select sum(a1.[Research Area])
--     from a as a1
--     where a1.[Fiscal Year] = 2024
--         and [Organization-Name] = 'Pharmacology and Toxicology') as [Over/Under]
-- from a as a
-- where [Organization-Name] = 'Pharmacology and Toxicology'

------------- MTDC SUMMARY

------------- Various Metrics



select *
from SpaceFunding
where 
[Organization-Name] = 'COM Phx Translational Neurosci'
    -- [Investigator Id] =  01830567
    and [Fiscal Year] = 2023

select sum([MTDC Base]) MTDC,
    sum(sf.[Total Expenses]) Expenses,
    SUM(sf.[Total Obligated Amount])
from [dbo].[SpaceFunding] sf

where 
[Fiscal Year] = 2021 and
    -- [Investigator Id] =  01830567 
    sf.[Investigator Name] = 'Abraham,Ivo L'

order by [Fiscal Year] desc


--??
-- and [Award Number] = '2606880'
and [Award Id] = '008000-00001'
order by [Investigator Id]
, [Fiscal Year] desc

select format(round(sum([Total Obligated Amount]),2),'N2') total_obliged
from [dbo].[SpaceFunding] sf
-- total number is not showing right
where [Investigator Id] = '22060596'
    and [Fiscal Year] != 2024

select format(round(sum([MTDC Base]),2),'N2') total_mtdc
from [dbo].[SpaceFunding] sf
-- total number is not showing right
where [Investigator Id] = '22060596'
    and [Fiscal Year] != 2024

    and [Award Number] = '2606880'
order by [Fiscal Year] desc

update mr
set mr.TotalAccrualSnapshot = e.NumberOfEnrollments,
mr.ExecutionTime = '2024-02-04'
from logs.MonthlyReminder mr
outer apply ( select sum(e.NumberOfEnrollments) NumberOfEnrollments from Enrollments e where mr.Protocol_No = e.Protocol_No and e.On_StudyDate < '2024-02-05') e
where cast(ExecutionTime as date ) = '2024-02-05'

select * from Enrollments order by On_StudyDate desc

select
protocol_no,
CREATED_DATE,
on_studydate,
sum(distinct case when institution = 'University of Arizona Health Sciences (UAHS)' then accrual end)as UAHS_Enrollments,
sum(distinct case when institution != 'University of Arizona Health Sciences (UAHS)' then accrual end)as Affiliates_Enrollments,
sum(distinct accrual) NumberOfEnrollments 
from ONCOREPROD..UACC_ONCORE_RW_UTILS.MYPSV2
--where protocol_no = '1000000478'
--and on_studydate is not null
	group by protocol_no
    , CREATED_DATE
    , on_studydate
    , subject_no

update mr
set mr.ExecutionTime = '2024-02-05',
mr.TotalAccrualSnapshot = e2.enr
from logs.MonthlyReminder mr
outer apply (select sum(e1.NumberOfEnrollments) enr from Enrollments e1 where e1.Protocol_No = mr.Protocol_No and e1.On_StudyDate < '2024-02-05') e1
outer apply (select sum(e2.NumberOfEnrollments) enr from Enrollments e2 where e2.Protocol_No = mr.Protocol_No and e2.created_date < '2024-02-05') e2
where cast(ExecutionTime as date) = '2024-02-05'

select l1.*, l2.TotalAccrualSnapshot as PreviousSnapShot from logs.MonthlyReminder l1
left join logs.MonthlyReminder l2 on l1.Protocol_No = l2.Protocol_No and cast(l2.ExecutionTime as date) = '2024-01-10'
where cast(l1.ExecutionTime as date) = '2024-02-05'

select * from logs.MonthlyReminder where cast(ExecutionTime as date) = '2024-01-10'
and Protocol_No = '1711048679'

select * from Protocols where protocol_no = '1711048679'

-- All studies (oncology & general medicine) that have been opened to accrual during 2023.
-- This would include a historical look, so any study that had this as a study status for the calendar year 2023. 
-- If their status changed in 2023 (e.g. closed to accrual, etc.), could I see the current status too?
-- List of fields	:	Protocol no., protocol type, protocol title (full), PI name, department,
-- management group (primary), total accrual numbers (to date), 
-- Protocol target accrual, Study Phase, Sponsor name, protocol status, 
-- NCT #, scope, Investigator Initiated protocol, investigational drug, investigational device

select *
    protocol_no,
    protocol_status,
    nct_number,
    department,
    title,
    phase_id,
    phase,
    scope_id,
    scope,
    investigator_initiated,
    protocol_type_id,
    protocol_type,
    investigational_drug,
    investigational_device,
    rare_disease,
    certs_of_confidentiality,
    created_user,
    created_date,
    modified_user,
    modified_date
FROM
    ONCOREPROD..UACC_ONCORE_PROD.RV_PROTOCOL_DETAILS



 order by protocol_no, status_date



 alter table protocols
 add Scope NVARCHAR(15)

 select * from protocols

 select * from ONCOREPROD..UACC_ONCORE_PROD.RV_PROTOCOL_DETAILS
