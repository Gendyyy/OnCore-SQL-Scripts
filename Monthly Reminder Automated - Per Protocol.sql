with
    TransformProtocols
    as
    (

        select
            case when p.pi_email = s.email_address then p.pi_email else s.email_address end EMAIL,
            p.PI_Email,
            s.staff_role,
            s.staff_name,
            p.protocol_no,
            case when primary_crc is null and primary_irb_coord is null then 1 else 0 end NoCoords
        from protocols p inner join staff s on p.protocol_id = s.protocol_id
        where 
        (ACTIVE_CONTACT_FLAG = 'Y' and (STOP_DATE is null or STOP_DATE > GETDATE()))
            and p.IsSummaryAccrual = 'Y'
            and stop_date is null
            and (p.current_status in ('NEW','UAHS RA SIGNOFF', 'SRC APPROVAL', 'IRB INITIAL APPROVAL' ,'OPEN TO ACCRUAL','SUSPENDED','ON-HOLD')
            or
            p.protocol_no in (select protocol_no
            from protocolstatushistory
            where lower(status) = 'closed to accrual' and status_date >= CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) AS DATE) )
            )
    )
	-- INSERT INTO oncorestaging.logs.MonthlyReminder 
    -- (Protocol_No, PI_Email, MembersEmails, MembersNames, MembersRoles, TotalAccrualSnapshot, ExecutionTime)
select
    tp.Protocol_No,
    max(PI_Email) as PI_Email,
    STRING_AGG(email,';') MembersEmails,
    string_agg(staff_name,' ; ') MembersNames,
    string_agg(staff_role,';') MembersRoles,
    max(e.numberofenrollments) TotalAccrualSnapshot,
    GETDATE() as ExecutionTime
from TransformProtocols tp
outer apply (select sum(e.numberofenrollments) numberofenrollments
    from Enrollments e
    where tp.protocol_no = e.Protocol_No
    group by e.Protocol_No ) e
where staff_role in
('Accrual Data Contact', 'Primary CRC', 'Primary IRB Coordinator')
    or
    (staff_role = 'Principal Investigator' and NoCoords =1)
group by tp.Protocol_No