SELECT p.protocol_id,
nvl((select listagg(to_char(submission_id),';') within group (order by submission_id) from uacc_oncore_prod.smrs_rcm_pcl_outcome where protocol_id = scr.protocol_id and outcome_id = scr.outcome_id),p.prmc_no) src_nos,
scr.protocol_no,
submit_date,
meeting_date review_date,
p.sponsor,
p.sponsor_type,
review_reason_desc review_reason_description,
action_desc decision,
parent_action_desc parent_decision,
action_effective_date decision_date,
re_review_date,
summary,
PI_name,
phase,
program_area,
IIT,
P.SUMMARY4_REPORT_DESC,
P.NCI_TX_TYPE protocol_type,
p.dmg primary_dmg,
extract(year from submit_date) SubmissionDateYear
FROM
SV_CC_CAC_REVIEW_RO scr join mypv4 p
on scr.protocol_id = p.protocol_id
and submit_date between '01-jan-202023' and '31-dec-2023'