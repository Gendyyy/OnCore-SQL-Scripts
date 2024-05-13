with Current_PIs as (select distinct pi_name,
                                     dbo.GetNetIDFromEmail(pi_email) Protocols_PI_Email_Prefix
                     from protocols
                     where pi_name is not null
                       and Current_Status != 'ABANDONED'
                       and (
                         (year(Current_Status_Date) >= year(getdate()) - 5 and
                          Current_Status in ('IRB STUDY CLOSURE', 'TERMINATED'))
                             or
                         Current_Status in ('IRB INITIAL APPROVAL',
                                            'UAHS RA SIGNOFF',
                                            'ON HOLD',
                                            'NEW',
                                            'SRC APPROVAL',
                                            'CLOSED TO ACCRUAL',
                                            'OPEN TO ACCRUAL',
                                            'SUSPENDED'
                             )
                         ))
   , PIs_Full_Info as (select s.*
                       from Staff s
                                join Current_PIs
                                     on pi_name = s.STAFF_NAME)

-- select count(distinct PIs_Full_Info.STAFF_NAME) from PIs_Full_Info
select 'Match with Union Based on (SOURCE:Full Name) --> (DESTINATION: Full Name)'               as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_union as u
         join PIs_Full_Info on LAST_NAME + ', ' + FIRST_NAME = STAFF_NAME
union
select 'Match with Union Based on (SOURCE:Email Prefix) --> (DESTINATION: NetID)'                as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_union as u
         join PIs_Full_Info on dbo.GetNetIDFromEmail(EMAIL_ADDRESS) = NETID_OPRID
union
select 'Match with Union Based on (SOURCE:Email Prefix) --> (DESTINATION: Email Prefix)'         as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_union as u
         join PIs_Full_Info on dbo.GetNetIDFromEmail(EMAIL_ADDRESS) = dbo.GetNetIDFromEmail(EMAIL_ADDR)
union
select 'Match with Union Based on (SOURCE:NetID) --> (DESTINATION:NetID)'                        as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_union as u
         join PIs_Full_Info on NETID = NETID_OPRID
union
select 'Match with Union Based on (SOURCE:Username) --> (DESTINATION: NetID)'                    as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_union as u
         join PIs_Full_Info on Username = NETID_OPRID
union
select 'Match with EML Based on (SOURCE:Full Name) --> (DESTINATION: Full Name)'                 as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_eml as e
         join PIs_Full_Info on STAFF_NAME = LAST_NAME + ', ' + FIRST_NAME
union
select 'Match with EML Based on (SOURCE:Email Prefix) --> (DESTINATION: NetID)'                  as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_eml as e
         join PIs_Full_Info on dbo.GetNetIDFromEmail(EMAIL_ADDRESS) = NETID_OPRID
union
select 'Match with EML Based on (SOURCE:Email Prefix) --> (DESTINATION: Email Prefix)'           as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_eml as e
         join PIs_Full_Info on dbo.GetNetIDFromEmail(EMAIL_ADDRESS) = dbo.GetNetIDFromEmail(EMAIL_ADDR)
union
select 'Match with EML Based on (SOURCE:NetId) --> (DESTINATION: NetID)'                         as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_eml as e
         join PIs_Full_Info on NETID = NETID_OPRID
union
select 'Match with EML Based on (SOURCE:Username) --> (DESTINATION: NetID)'                      as Metric,
       cast(count(distinct EMPLID) as varchar) + '/' +
       cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as varchar)                                 'Match/Total',
       format(count(distinct EMPLID)
                  / cast((select count(distinct STAFF_NAME) from PIs_Full_Info) as float), 'P2') as Percentage
from dtrust_proxy.med_faculty_eml as e
         join PIs_Full_Info on Username = NETID_OPRID