
-- SELECT * FROM OPENQUERY(ONCOREPROD,'select COUNT(*) from ONCOREPROD..UACC_ONCORE_RW_UTILS.AEGIS_VISITS_STUDY00000158 where actual_visit_date between ''28-SEP-2022'' and ''01-SEP-2023''
-- AND PROTOCOL_NO = ''STUDY00000158''')

select COUNT(*) from ONCOREPROD..UACC_ONCORE_RW_UTILS.AEGIS_VISITS_STUDY00000158 where actual_visit_date between '28-SEP-2022' and '01-SEP-2023'
AND PROTOCOL_NO = 'STUDY00000158'

-- Export the results to excel
-- Name the file RECOVER_PROCEDURES_2023_02.XLSX
-- upload the excel file to Box Health>OnCore IT>RECOVER PROCEDURES

-- with staff as (select * from uacc_oncore_sv_pcl_staff_ro
-- where active_user_flag = 'Y' and staff_role in ('Accrual Data Contact', 'Primary CRC', 'Primary IRB Coordinator','Principal Investigator') and protocol_subject_id is null;

-- test