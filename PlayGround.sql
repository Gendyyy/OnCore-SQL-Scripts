
-- below is working
EXEC ('delete from [CLINICALTRIALDATA].[DBO].[PIMONTHLYREMINDER]') at [COM-DTRUST-PROD.BLUECAT.ARIZONA.EDU]

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
    INSERT INTO [COM-DTRUST-PROD.BLUECAT.ARIZONA.EDU].[ClinicalTrialData].[DBO].[PIMonthlyReminder] (subject, email, staff_name, NumberOfProtocols, Staff_Roles, ListOfProtocols)
select
    'Monthly Reminder to Update OnCore for Quarterly Report' subject,
    email,
    staff_name,
    count(protocol_no) NumberOfProtocols,
    STRING_AGG(staff_role,',') Staff_Roles,
    string_agg(Protocol_No,',') ListOfProtocols
from TransformProtocols tp
where staff_role in
('Accrual Data Contact', 'Primary CRC', 'Primary IRB Coordinator')
    or
    (staff_role = 'Principal Investigator' and NoCoords =1)
group by email,staff_name
--    '
-- ) AT [COM-DTRUST-PROD.BLUECAT.ARIZONA.EDU];



select 

'Monthly Reminder to Update OnCore for Quarterly Report' as subject,
N'gendy@arizona.edu' as email,
N'' staff_name,
2 as NumberOfProtocols,
N'' as Staff_Roles,
N'STUDY00000562(Y),STUDY00000562(Y)' as ListOfProtocols
union
select
'Monthly Reminder to Update OnCore for Quarterly Report' as subject,
N'bsherchand@arizona.edu' as email,
N'' staff_name,
2 as NumberOfProtocols,
N'' as Staff_Roles,
N'STUDY00000562(Y),STUDY00000562(Y)' as ListOfProtocols

select 

'Protocol "1909985869" Monthly Reminder to Update OnCore for Quarterly Report' as subject,
'1909985869' Protocol_No,
N'bsherchand@arizona.edu' PI_Email,
N'gendy@arizona.edu;gendy@arizona.edu;shelbylegendre@arizona.edu' MembersEmails,
N'Algendy, Ahmed;Algendy, Ahmed;LeGendre, Shelby' MembersNames,
N'Primary CRC;Primary IRB Coordinator' MembersRoles

select 

'Protocol "1909985869" Monthly Reminder to Update OnCore for Quarterly Report' as subject,
'1909985869' Protocol_No,
N'' PI_Email,
-- N'gendy@arizona.edu;gendy@arizona.edu;shelbylegendre@arizona.edu' MembersEmails,
N'gendy@arizona.edu;gendy@arizona.edu' MembersEmails,
N'Algendy, Ahmed;Algendy, Ahmed' MembersNames,
N'Primary CRC;Primary IRB Coordinator' MembersRoles



select top 10

protocol_id,
protocol_no,
Title,
pi_name,
PI_Email,
dmg as ManagementGroup,
Protocol_Institutions,
Department_Name,
[Library],

Data_Monitoring,
accrual_summary,
Target_Accrual as LowerTargetAccrual,
Target_Accrual_Upper as UpperTargetAccrual
Current_Status,
Current_Status_Date,

Created_Date,
Initial_Open_Date,
Closed_Date,
Study_Closure_Date,
primary_crc,
primary_irb_coord,
sponsor,
len(SPONSOR_NUMBER)

from ONCOREPROD..UACC_ONCORE_RW_UTILS.PROTOCOLS
where protocol_no is not null
order by len(SPONSOR_NUMBER) desc


use OnCoreDW
-- select * from Protocols where protocol_no in ('36504','37324')
select * from dw.FactProtocols where protocol_no in ('36504','37324','STUDY00001721')

select * from oncoredw.dw.FactProtocols where protocol_no = '2002421904'
select * from oncoredw.dw.FactEnrollments where Protocol_Key = '2235'

select * from oncorestaging.dbo.enrollments  e
where
-- protocol_no = '2002421904'
e.uahs_enrollments is not null and e.affiliates_enrollments is not null
select * from oncorestaging.dbo.protocols where protocol_no = '2002421904'

select * from ONCOREPROD..UACC_ONCORE_RW_UTILS.ACUITY_REPORT_ONCOLOGY_REV2