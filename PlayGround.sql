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
            sf.[Organization-Name] ,
            sf.[Investigator Name] ,
            sf.[Investigator Id] ,
            format(round(sum(sf.[MTDC Base]),0),'N0') MTDC,
            format(round(sum(sf.[Total Expenses]),0),'N0') Expenditures,
            -- format(round(sum(sf.[Area by PI]),0),'N0') [Research Area],
            round(sum(sf.[Area by PI]),0) [Research Area],
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
                -- [Investigator Name] != '-'
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

6954065.137844424

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


