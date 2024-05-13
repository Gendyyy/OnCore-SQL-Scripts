with a as (select *
           from UACC_ONCORE_PROD.sv_subject_forms sf
                    join UACC_ONCORE_PROD.sv_pcs_form_status_history fsh on sf.SD_PCS_FORM_ID = fsh.SD_PCS_FORM_ID
           where STATE = 'Validated'
             and STATE_UNDO = 'N'
           )

select
    distinct
       psb.PROTOCOL_NO,
       psb.PROTOCOL_SUBJECT_ID,
       psb.SUBJECT_MRN,
       psb.SUBJECT_STATUS,
       a.VISIT_STRING Visit_Title,
       a.CLINICAL_PROCEDURE,
       a.FORM_NO,
       a.VISIT_DATE,
       a.CREATED_DATE Validation_Date
from UACC_ONCORE_PROD.RV_PROTOCOL_SUBJECT_BASIC psb
    join MYPV4 p on psb.PROTOCOL_ID = p.PROTOCOL_ID
join a on a.PROTOCOL_SUBJECT_ID = psb.PROTOCOL_SUBJECT_ID
where p.LIBRARY = 'Oncology'
-- where psb.PROTOCOL_NO = '0700000327'
--   and SUBJECT_MRN = '9463100'
order by PROTOCOL_NO,SUBJECT_MRN, VISIT_DATE