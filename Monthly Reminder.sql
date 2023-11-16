with
    staff
    as
    (
        SELECT staff_name, staff_role, email_address, protocol_id, active_user_flag, stop_date
        from UACC_ONCORE_RW_UTILS.SV_PCL_STAFF_RO
        where active_user_flag = 'Y' and staff_role in ('Accrual Data Contact', 'Primary CRC',
         'Primary IRB Coordinator','Principal Investigator')
            and protocol_subject_id is null
    )
--2/21/2023 --removed role based on subject assignment which should reflect when removed from protocol but not subject.

select email, 'Monthly Reminder to Update OnCore for Quarterly Report' subject, staff_name,
    sum(NumberOfProtocols) NumProtocols, listagg(distinct protocol_no, '<br>'
on overflow
truncate
with count) within group
(order by staff_role) ProtocolNos,
listagg
(distinct staff_role,',' on overflow
truncate
with count) within group
(order by staff_role) staff_roles
from
(
    select a.protocol_no || case when accrual_summary = 'Y' then '(Y)' else null end protocol_no, staff_role, staff_name,
    case when pi_email = email_address then 1 else 0 end EMAIL2,
    case when pi_email = email_address then pi_email else email_address end EMAIL, email_address, pi_email,
    count(*) NumberOfProtocols,
    case when primary_crc is null and primary_irb_coord is null then 1 else 0 end NoCoords
from UACC_ONCORE_RW_UTILS.PROTOCOLS a left join staff r on r.protocol_id = a.protocol_id
where active_user_flag = 'Y' and staff_role in ('Accrual Data Contact', 'Primary CRC', 'Primary IRB Coordinator','Principal Investigator') 
and stop_date is null
    and (a.current_status in ('NEW','UAHS RA SIGNOFF', 'SRC APPROVAL', 'IRB INITIAL APPROVAL' ,'OPEN TO ACCRUAL','SUSPENDED','ON-HOLD')
    or A.protocol_id in (select protocol_id
    from UACC_ONCORE_PROD.SV_PCL_STATUS
    where status = 'CLOSED TO ACCRUAL' AND status_date > '01-jul-2022')
        )

group by staff_role,staff_name, email_address, pi_email, a.protocol_no || case when accrual_summary = 'Y' then '(Y)' else null end  ,primary_crc,primary_irb_coord
    )
xx
    where staff_role in
('Accrual Data Contact', 'Primary CRC', 'Primary IRB Coordinator')
    or
(staff_role = 'Principal Investigator' and NoCoords =1)
   
    group by staff_name,email
 ;

