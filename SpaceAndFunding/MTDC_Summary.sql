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