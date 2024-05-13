select * from (select row_number() over (partition by s.PROTOCOL_NO, s.STAFF_ROLE
    order by s.PROTOCOL_NO,
        s.STAFF_ROLE,
        s.ACTIVE_FLAG desc,
        s.STOP_DATE desc
    ) as RowNumber,
                               s.PROTOCOL_NO,
                               s.STAFF_ROLE,
                               s.STAFF_NAME
                        from SV_PCL_STAFF_RO s
                        where staff_role in ('Accrual Data Contact',
                                             'Primary RDC',
                                             'Primary CRC',
                                             'Clinical Research Coordinator',
                                             'Primary IRB Coordinator',
                                             'IRB Coordinator',
                                             'Principal Investigator')
                          and s.PROTOCOL_SUBJECT_ID is null) a
pivot(

        max(a.STAFF_NAME) for STAFF_ROLE in ('Accrual Data Contact',
                                             'Primary RDC',
                                             'Primary CRC',
                                             'Clinical Research Coordinator',
                                             'Primary IRB Coordinator',
                                             'IRB Coordinator',
                                             'Principal Investigator')
    )
where RowNumber = 1
