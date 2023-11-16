with
    TransformProtocols
    as
    (

        select
            case when p.pi_email = s.email_address then p.pi_email else s.email_address end EMAIL,
            s.staff_role,
            s.staff_name,
            CONCAT(p.protocol_no,case when p.accrual_summary = 'Y' then '(Y)' else null end) Protocol_No,
            case when primary_crc is null and primary_irb_coord is null then 1 else 0 end NoCoords
        from protocols p left join staff s on p.protocol_id = s.protocol_id
        where active_user_flag = 'Y'
            and stop_date is null
            and (p.current_status in ('NEW','UAHS RA SIGNOFF', 'SRC APPROVAL', 'IRB INITIAL APPROVAL' ,'OPEN TO ACCRUAL','SUSPENDED','ON-HOLD')
            or
            p.protocol_no in (select protocol_no
            from protocolstatushistory
            where lower(status) = 'closed to accrual' and status_date > @ClosedDate )
)
    )
select
    'Monthly Reminder to Update OnCore for Quarterly Report' subject,
    email,
    staff_name,
    count(protocol_no) NumberOfProtocols,
    STRING_AGG(staff_role,',') Staff_Roles,
    string_agg(Protocol_No,'<br>') ListOfProtocols
from TransformProtocols tp
where staff_role in
('Accrual Data Contact', 'Primary CRC', 'Primary IRB Coordinator')
    or
    (staff_role = 'Principal Investigator' and NoCoords =1)
group by email,staff_name

SELECT cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) as date)