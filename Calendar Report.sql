select ch.*
from
    [dbo].[ProtocolCalendarStatusHistory] ch
    inner join protocols p on p.protocol_id = ch.protocol_id
where
    p.Library in (
        'Oncology',
        'General Medicine'
    )
    and ch.strikethrough = 'N'

SELECT
    protocol_id,
    protocol_no,
    version_no,
    len(status),
    strikethrough,
    len(created_user),
    created_date
FROM
    ONCOREPROD..UACC_ONCORE_PROD.SV_STUDY_SPEC_STATUS_HISTORY
WHERE
    PROTOCOL_NO IN (
        '2009015316',
        --SUSIE FIRST
        '2005630160',
        -- WENDY
        '2102537612'
    ) --SUSIE SECOND
ORDER BY
    PROTOCOL_NO,
    CREATED_DATE;

select *
from (
        select
            s.*,
            case
                when status = 'New' then 1
                when status = 'Completed' then 2
                when status = 'Coordinator Signoff' then 3
                when status = 'Released' then 4
                else 0
            end rankStatus,

case
    when strikethrough = 'N' then case
        when status = 'New' then 1
        when status = 'Completed' then 2
        when status = 'Coordinator Signoff' then 3
        when status = 'Released' then 4
        else 0
    end
    else 0
end rankStatus2

--select *

from
    uacc_oncore_prod.sv_study_spec_status_history s
WHERE
    PROTOCOL_NO IN (
        '2009015316',
        --SUSIE FIRST
        '2005630160',
        -- WENDY
        '2102537612'
    ) --SUSIE SECOND
order by
    protocol_id,
    rankstatus2,
    created_date
) xx;

with rws as (
        select
            s.*,
            row_number() over (
                partition by protocol_id
                order by
                    version_no desc,
                    case
                        when strikethrough = 'N' then case
                            when status = 'New' then 1
                            when status = 'Completed' then 2
                            when status = 'Coordinator Signoff' then 3
                            when status = 'Released' then 4
                            else 0
                        end
                        else 0
                    end desc,
                    created_date desc
            ) rn

from
    uacc_oncore_prod.sv_study_spec_status_history s
WHERE
    PROTOCOL_NO IN (
        '2009015316',
        --SUSIE FIRST
        '2005630160',
        -- WENDY
        '2102537612',
        --SUSIE SECOND
        '1609876907'
    ) -- 41 records
    and version_no = 1
)
select *
from rws
where rn = 1
order by
    protocol_no,
    version_no,
    created_date desc;

select
    protocol_id,
    protocol_no,
    count(*)
from
    uacc_oncore_prod.sv_study_spec_status_history s
group by
    protocol_id,
    protocol_no;

with rw as (
        select
            s.*,
            row_number() over (
                partition by protocol_id
                order by
                    case
                        when status = 'New' then 1
                        when status = 'Completed' then 2
                        when status = 'Coordinator Signoff' then 3
                        when status = 'Released' then 4
                        else 0
                    end desc
            ) rn

from
    uacc_oncore_prod.sv_study_spec_status_history s
WHERE
    PROTOCOL_NO IN (
        '2009015316',
        --SUSIE FIRST
        '2005630160',
        -- WENDY
        '2102537612',
        --SUSIE SECOND
        '1609876907'
    ) -- 41 records
    and version_no = 1
    and strikethrough = 'N'
)
select *
from rw
where rn = 1
order by protocol_id;