WITH
    param
    as
    (
        SELECT TO_DATE($P
    
    {Start_Date}) PSTARTDATE, TO_DATE
( $P{End_Date} ) PENDDATE,  $P{irb}  PIRBC,  $P{MGMT_GROUP} PMGMT_GROUP FROM DUAL)
, irbDATES AS
SELECT p.PI_Name piname, p.protocol_no, p.study_target_accrual, p.title, p.total_accrual totalonstudy,
    i.maxeffectivedate, i.maxexpireddate,
    g.sponsor_name, g.sponsor_protocol_no,
    c.irbcoord_name
FROM uacc_oncore_rw_utils.protocols p 
       CROSS JOIN PARAM
    LEFT JOIN uacc_oncore_prod.sv_pcl_sponsor g ON p.protocol_id = g.protocol_id
    LEFT JOIN ( SELECT PROTOCOL_ID, first_name, last_name, FIRST_NAME || ' ' || LAST_NAME  irbcoord_name, stop_date
    FROM uacc_oncore_rw_utils.sv_pcl_staff_ro
    WHERE staff_role = 'Primary IRB Coordinator' AND ACTIVE_FLAG = 'Y' and protocol_subject_id is null ) c ON p.protocol_id = c.protocol_id
       outer apply (select top 1
        protocol_id, PROTOCOL_NO, ACTION_DATE maxeffectivedate, EXPIRATION_DATE maxexpireddate, review_expires
    from uacc_oncore_prod.rv_pcl_irb_review r
    where 
              r.PROTOCOL_ID = P.PROTOCOL_ID
              REVIEW_REASON
IN
('Continuing Review','Initial Review')
              order by maxexpireddate desc
              ) I
  WHERE CURRENT_status NOT IN
( 'ABANDONED', 'TERMINATED', 'IRB STUDY CLOSURE', 'NEW','SRC APPROVAL' )
   AND maxexpireddate BETWEEN PSTARTDATE AND PENDDATE
   AND
((irbcoord_name LIKE '%' || PIRBC || '%' and
(stop_date > sysdate or stop_date is null)) OR PIRBC IS NULL)
   AND
(ALL_DMG LIKE  '%' || PMGMT_GROUP || '%' OR PMGMT_GROUP IS NULL )
   and g.principal_sponsor = 'Y'
   and i.review_expires = 'Y'
order by PI_NAME, PROTOCOL_NO