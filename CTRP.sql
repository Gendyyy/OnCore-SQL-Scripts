WITH prot AS (
  SELECT t.*, ROWNUM AS subject_no,
         (SELECT nci_ctrp_id FROM protocols WHERE protocol_id = t.protocol_id) AS nci_ctrp_id,
         (SELECT protocol_no FROM protocols WHERE protocol_id = t.protocol_id) AS protocol_no,
         (SELECT institution_name FROM uacc_oncore_prod.sv_pcl_institution WHERE protocol_id = t.protocol_id) AS INSTITUTION
  FROM (
    SELECT * FROM uacc_oncore_prod.smrs_pcl_accrual_summary t
    WHERE t.protocol_id = (SELECT protocol_id FROM protocols WHERE protocol_no = 'STUDY00002169')
  ) t,
  TABLE(
    CAST(MULTISET(SELECT ROWNUM r FROM DUAL CONNECT BY LEVEL <= t.accrual) AS sys.ODCINUMBERLIST)
  )
)
-- Retrieve 'COLLECTIONS' data
SELECT
  '"COLLECTIONS",' || '"' || TRIM(nci_CTRP_id) || '"' || ',,,,,,,,,' A
FROM
  UACC_ONCORE_RW_UTILS.mypv4
WHERE
  PROTOCOL_NO = 'STUDY00002169'

union
-- Detailed patient data extraction with demographics and treatment details

SELECT
  '"PATIENTS",' ||
  '"' || TRIM(p.NCI_CTRP_ID) || '",' ||
  '"' || p.SUBJECT_NO || '",' ||
  '"' || ZIP_CODE || '",' ||
  '"US",' ||
  '"' || CASE AGE_GROUP
    WHEN '0-9' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 5) || '12'
    WHEN '10-19' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 10) || '01'
    WHEN '20-29' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 20) || '02'
    WHEN '30-39' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 30) || '03'
    WHEN '40-49' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 40) || '04'
    WHEN '50-59' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 50) || '05'
    WHEN '60-69' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 60) || '06'
    WHEN '70-79' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 70) || '07'
    WHEN '80-89' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 80) || '08'
    WHEN '90-99' THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 90) || '09'
    WHEN '100+'  THEN TO_CHAR(EXTRACT(YEAR FROM FROM_DATE) - 100) || '10'
    ELSE '197011'
  END || '",' ||
  '"' || COALESCE(BS.NAME, 'Unknown') || '",' ||
  '"' || CASE e.description
    WHEN 'Non-Hispanic' THEN 'Not Hispanic or Latino'
    WHEN 'Hispanic or Latino' THEN 'Hispanic or Latino'
    ELSE 'Unknown'
  END || '",' ||
  '"Unknown",' ||
  '"' || TO_CHAR(from_date, 'yyyymmdd') || '",,' ||
  '"' || (SELECT MAX(org_id_type_identifier) FROM uacc_oncore_prod.rv_organization_identifier WHERE organization_name = P.INSTITUTION AND organization_id_type_name = 'NCI PO ID') || '"' || ',,,,,,,,,,' ||
  '"172"' || ',,' A
FROM prot p
LEFT JOIN uacc_oncore_prod.sv_ethnicity e ON p.ethnicity = e.code_id
LEFT JOIN UACC_ONCORE_PROD.BIOLOGICAL_SEX BS ON BS.BIOLOGICAL_SEX_ID = p.BIOLOGICAL_SEX_ID
LEFT JOIN uacc_oncore_prod.sv_race r ON p.race = r.code_id
WHERE p.PROTOCOL_NO = 'STUDY00002169'
-- ORDER BY p.subject_no

-- Patient races data extraction

union

SELECT
  '"PATIENT_RACES",' ||
  '"' || TRIM(p.NCI_CTRP_ID) || '",' ||
  '"' || p.SUBJECT_NO || '",' ||
  '"' || r.DESCRIPTION || '"' A
FROM prot p
LEFT JOIN UACC_ONCORE_PROD.SV_RACE R ON P.RACE = R.CODE_ID
WHERE p.PROTOCOL_NO = 'STUDY00002169'
-- ORDER BY p.subject_no;
