-- Protocols Non-Summary Accrual and Don't have Calendar
select distinct p.protocol_no, p.Title, p.Current_Status from protocols p left outer join ProtocolCalendarStatusHistory ch on  p.protocol_id = ch.protocol_id
where ch.protocol_id is null and p.Accrual_Summary <> 'Y'

select * from [dbo].[Enrollments]



-- Declare @LinkedServer nvarchar(50) = '[COM-DTRUST-PROD.BLUECAT.ARIZONA.EDU].[ClinicalTrialData].[dbo].'

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
    INSERT INTO [ClinicalTrialData].[DBO].[PIMonthlyReminder] (subject, email, staff_name, NumberOfProtocols, Staff_Roles, ListOfProtocols)
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

create table .[ClinicalTrialData].[PIMonthlyReminder](
[subject] nvarchar(100),
email nvarchar(50),
staff_name nvarchar(35),
NumberOfProtocols NUMERIC(2,0),
Staff_Roles NVARCHAR(600),
ListOfProtocols NVARCHAR(600),
)
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

DECLARE @LinkedServer NVARCHAR(128) = N'[COM-DTRUST-PROD.BLUECAT.ARIZONA.EDU]'
DECLARE @TableName NVARCHAR(128) = N'[DBO].[PIMonthlyReminder]';
DECLARE @DatabaseName NVARCHAR(128) = 'ClinicalTrialData';
DECLARE @LinkedServerName NVARCHAR(128) = 'TEST.ARIZONA.EDU';

-- Build the dynamic SQL query to truncate the table
DECLARE @SqlStatement NVARCHAR(MAX);

SET @SqlStatement = N'TRUNCATE TABLE ' + QUOTENAME(@LinkedServerName) + '.' + QUOTENAME(@DatabaseName) + '.' + @TableName;

-- Execute the dynamic SQL query
EXEC (@SqlStatement) AT [COM-DTRUST-PROD.BLUECAT.ARIZONA.EDU];

select 

'Monthly Reminder to Update OnCore for Quarterly Report' as subject,
N'gendy@arizona.edu' as email,
N'' staff_name,
2 as NumberOfProtocols,
N'' as Staff_Roles,
N'STUDY00000562(Y),STUDY00000562(Y)' as ListOfProtocols,
'Monthly Reminder to Update OnCore for Quarterly Report' as subject,
N'bsherchand@arizona.edu' as email,
N'' staff_name,
2 as NumberOfProtocols,
N'' as Staff_Roles,
N'STUDY00000562(Y),STUDY00000562(Y)' as ListOfProtocols