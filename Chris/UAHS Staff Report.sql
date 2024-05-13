-- staff report
with s as (select *
           from SV_PCL_STAFF_RO s
           where s.ACTIVE_FLAG = 'Y'
             and s.STOP_DATE is null
             and s.PROTOCOL_SUBJECT_ID is null)
   , management_group_list as (select rmsm.contact_id,
                                      mg.name
                               from UACC_ONCORE_PROD.onc_contact_ou_mgmt_group rmsm
                                        inner join
                                    UACC_ONCORE_PROD.onc_org_unit_management_group rmg
                                    on rmsm.onc_ou_mgmt_group_id = rmg.onc_ou_mgmt_group_id
                                        inner join
                                    UACC_ONCORE_PROD.onc_management_group mg
                                    on rmg.onc_management_group_id = mg.onc_management_group_id)

   , a as (select distinct mgl.NAME "Managmenet Group",
                           s.STAFF_ROLE,
                           s.STAFF_NAME,
                           s.TITLE  "Job Title"

           from s
                    join management_group_list mgl on mgl.CONTACT_ID = s.CONTACT_ID
           order by mgl.NAME, STAFF_ROLE)
select *
from a
where STAFF_ROLE not in
      ('1572-INV', 'Advisor', 'Biostatistician', 'Clinical Pharmacist', 'Co-Investigator', 'Consenting Physician',
       'Dignity Coordinator',
    'Graduate Assistant', 'MRI Technician', 'PCONTACT',
    'Pharmacy Technician', 'Primary Investigator', 'Protocol Adviser', 'Protocol Contact Person',
    'Referring Physician', 'ROI Covered Individual',
    'Treating Physician')
    and STAFF_ROLE not like '%-Principal Investigator%'
    and STAFF_ROLE not like 'Investigator%'
    and STAFF_ROLE not like '%DSMB% %Monitor%'
    and STAFF_ROLE not like 'Finance%'
    and STAFF_ROLE not like 'Investigational Pharmacist%'
    and STAFF_ROLE not like 'Phamacokinetics%'
    and STAFF_ROLE not like 'Statistician%'
    and STAFF_ROLE not like 'Sub-Investigator%'