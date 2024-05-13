with OpenToAccrualIn2023 as (select ps1.protocol_no,
                                    max(case when ps1.status = 'OPEN TO ACCRUAL' then ps1.status_date end)   as OpenToAccrualDate,
                                    max(case when ps1.status = 'ON HOLD' then ps1.status_date end)           as OnHoldDate,
                                    max(case when ps1.status = 'SUSPENDED' then ps1.status_date end)         as SuspendedDate,
                                    max(case when ps1.status = 'CLOSED TO ACCRUAL' then ps1.status_date end) as ClosedToAccrualDate
                             from ProtocolStatusHistory ps1
                             group by ps1.protocol_no
                             having
                                 max(case when ps1.status = 'OPEN TO ACCRUAL' then ps1.status_date end) <= '2023-12-31'
                                and (
                                 ((max(case when ps1.status = 'ON HOLD' then ps1.status_date end) between '2023-01-01' and '2023-12-31') or
                                  (max(case when ps1.status = 'ON HOLD' then ps1.status_date end) is null)) and
                                 ((max(case when ps1.status = 'SUSPENDED' then ps1.status_date end) between '2023-01-01' and '2023-12-31') or
                                  (max(case when ps1.status = 'SUSPENDED' then ps1.status_date end) is null)) and
                                 ((max(case when ps1.status = 'CLOSED TO ACCRUAL' then ps1.status_date end) between '2023-01-01' and '2023-12-31') or
                                  (max(case when ps1.status = 'CLOSED TO ACCRUAL' then ps1.status_date end) is null))))

select p.protocol_no,
       p.Title,
       p.pi_name,
       p.Department_Name,
       p.ManagementGroup,
       e.TotalAccruals,
       p.TotalAccrualTarget,
       p.phase,
       p.Sponsor,
       p2.protocol_status,
       p.nct_id,
       p.scope,
       p2.investigational_drug,
       p2.investigational_device,
       p2.investigator_initiated,
       psh.OpenToAccrualDate,
       psh.OnHoldDate,
       psh.SuspendedDate,
       psh.ClosedToAccrualDate
from Protocols p
         left join (select *
                    from openquery(ONCOREPROD, 'select protocol_id, protocol_no, protocol_status, investigational_drug, investigational_device
 ,investigator_initiated from UACC_ONCORE_PROD.RV_PROTOCOL_DETAILS') p2) as p2 on p.protocol_id = p2.protocol_id
         inner join OpenToAccrualIn2023 psh on psh.protocol_no = p.protocol_no
         outer apply(select sum(e.NumberOfEnrollments) TotalAccruals
                     from Enrollments e
                     where e.Protocol_No = p.protocol_no) e