use OnCoreStaging
go
select p.protocol_no,
    CompletedCal.status SentForValidation,
    isnull(CRCCal.[status], 'No-CRC SignOff') IsSigned,
    dbo.businessdaysduration(CompletedCal.created_date, getdate()) durationToday,
    case
        when dbo.businessdaysduration(CompletedCal.created_date, getdate()) >= 21 then '21 Days Reminder'
        when dbo.businessdaysduration(CompletedCal.created_date, getdate()) >= 15 then '15 Days Reminder'
        when dbo.businessdaysduration(CompletedCal.created_date, getdate()) >= 7 then '7 Days Reminder'
        else 'No Reminder'
    end as Email
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
where CompletedCal.[status] is not null -- and dbo.businessdaysduration(CompletedCal.created_date, getdate()) > 7
    and CRCCal.[status] is null