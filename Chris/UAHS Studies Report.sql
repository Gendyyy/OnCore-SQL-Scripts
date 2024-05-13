with s as (select *
           from SV_PCL_STAFF_RO s
           where s.ACTIVE_FLAG = 'Y'
             and s.STOP_DATE is null
             and s.PROTOCOL_SUBJECT_ID is null)

select p.DMG Management_Group,
                  p.PROTOCOL_NO,
                  p.CURRENT_STATUS,
                  p.TITLE,
                  p.PI_NAME
--        s.MANAGEMENT_GROUP_LIST "Staff Management Groups",

           from MYPV4 p
           where lower(p.CURRENT_STATUS) in ('new', 'closed to accrual')
           order by dmg, CURRENT_STATUS, p.PROTOCOL_NO