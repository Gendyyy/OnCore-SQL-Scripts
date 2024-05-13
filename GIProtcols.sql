with staff_cte as (select s.PROTOCOL_ID,
                          max(iif(s.STAFF_ROLE = 'Primary RDC', s.STAFF_NAME, '')) as Primary_RDC,
                          max(iif(s.STAFF_ROLE = 'Primary CRC', s.STAFF_NAME, '')) as Primary_CRC
                   from staff s
                   group by s.PROTOCOL_ID)
select p.protocol_no Protocol_No,
       sc.Primary_CRC,
       sc.Primary_RDC,
       p.pi_name     PI_Name,
       s.initials    Subject_Initials,
       s.status      Subject_Status

from protocols p
         left join ONCOREPROD..UACC_ONCORE_PROD.SV_PCL_ACCRUAL_DTL s on p.protocol_id = s.protocol_id
         left join staff_cte sc on sc.PROTOCOL_ID = p.protocol_id
where lower(p.Current_Status) in ('open to accrual', 'closed to accrual')
  and lower(p.ManagementGroup) like 'gas%'
