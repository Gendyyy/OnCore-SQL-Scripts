select p.protocol_no,
    p.Title,
    p.Current_Status,
    p.pi_name,
    p.sponsor,
    p.sponsorNo,
    staff.PI_Email,
    staff.PrimaryCRCEmails,
    staff.PrimaryCRCNames,
    staff.PrimaryIRBCEmail,
    staff.PrimaryIRBCName,
    CompletedCal.status SentForValidation,
    CompletedCal.created_date SentForValidationDate,
    isnull(CRCCal.[status], 'No-CRC SignOff') IsSigned,
    dbo.businessdaysduration(CompletedCal.created_date, getdate()) DaysSinceCalendarCompleted,
    case
        when dbo.businessdaysduration(CompletedCal.created_date, getdate()) >= 21 then '21 Days Reminder'
        when dbo.businessdaysduration(CompletedCal.created_date, getdate()) >= 15 then '15 Days Reminder'
        when dbo.businessdaysduration(CompletedCal.created_date, getdate()) >= 7 then '7 Days Reminder'
        else 'No Reminder'
    end as EmailType
    
from Protocols p
    cross apply (
        select max(ch.status) status,
            max(created_date) created_date,
            max(version_no) version_n
        from ProtocolCalendarStatusHistory ch
        where p.protocol_id = ch.protocol_id
            and ch.[status] = 'Completed'
            and ch.strikethrough = 'N'
    ) CompletedCal
    outer apply (
        select max(ch.status) status,
            max(created_date) created_date,
            max(version_no) version_n
        from ProtocolCalendarStatusHistory ch
        where p.protocol_id = ch.protocol_id
            and ch.[status] in ('Coordinator Signoff', 'Released')
            and ch.strikethrough = 'N'
    ) CRCCal
    cross apply(
        select STRING_AGG(
                case
                    when s.STAFF_ROLE = 'Primary CRC' then s.EMAIL_ADDRESS
                end,
                ';'
            ) PrimaryCRCEmails,
            STRING_AGG(
                case
                    when s.STAFF_ROLE = 'Primary CRC' then s.STAFF_NAME
                end,
                ';'
            ) PrimaryCRCNames,
            max(
                case
                    when s.STAFF_ROLE = 'Principal Investigator' then s.EMAIL_ADDRESS
                end
            ) as PI_Email,
            max(
                case
                    when s.STAFF_ROLE = 'Primary IRB Coordinator' then s.EMAIL_ADDRESS
                end
            ) as PrimaryIRBCEmail,
            MAX(case
                    when s.STAFF_ROLE = 'Primary IRB Coordinator' then s.STAFF_NAME
                end) as PrimaryIRBCName
        from staff s
        where s.PROTOCOL_ID = p.protocol_id
    ) Staff
where p.Current_Status not in ('ABANDONED', 'ON HOLD', 'IRB STUDY CLOSURE')
    and CompletedCal.[status] is not null -- and dbo.businessdaysduration(CompletedCal.created_date, getdate()) > 7
    and CRCCal.[status] is null 