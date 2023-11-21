
use OnCoreStaging
go
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
        active_user_flag = 'Y'
            and p.accrual_summary = 'Y'
            and stop_date is null
            and (p.current_status in ('NEW','UAHS RA SIGNOFF', 'SRC APPROVAL', 'IRB INITIAL APPROVAL' ,'OPEN TO ACCRUAL','SUSPENDED','ON-HOLD')
            or
            p.protocol_no in (select protocol_no
            from protocolstatushistory
            where lower(status) = 'closed to accrual' and status_date >= CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) AS DATE) )
            )
    )
    -- INSERT INTO [COM-DTRUST-PROD.BLUECAT.ARIZONA.EDU].[ClinicalTrialData].[DBO].[PIMonthlyReminder] (subject, email, staff_name, NumberOfProtocols, Staff_Roles, ListOfProtocols)
select
    'Monthly Reminder to Update OnCore for Quarterly Report' subject,
    Protocol_No,
    max(PI_Email) as PI_Email,
    STRING_AGG(email,',') membersEmails,
    string_agg(staff_name,' ; ') membersNames,
    string_agg(staff_role,',') membersRoles
from TransformProtocols tp
where staff_role in
('Accrual Data Contact', 'Primary CRC', 'Primary IRB Coordinator')
    or
    (staff_role = 'Principal Investigator' and NoCoords =1)
group by Protocol_No