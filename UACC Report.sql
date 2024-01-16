select s.ACCRUAL,
    NVL(p.accrual_summary, 'N') ACCRUAL_SUMMARY_METHOD_YN,
    s.PROTOCOL_NO,
    s.PROTOCOL_SUBJECT_ID,
    s.SUBJECT_NO,
    s.SUBJECT_MRN,
    S.SEQUENCE_NUMBER,
    S.BIRTH_DATE,
    trunc(
        (
            TO_DATE(INITIAL_OPEN_DATE, 'MM/DD/YYYY') - BIRTH_DATE
        ) / 365
    ) AGE_ON_STUDY,
    S.AGE_GROUP,
    S.GENDER,
    S.ETHNICITY,
    S.RACE,
    S.TREATING_SITE,
    S.CONSENT_DATE,
    EXTRACT(
        MONTH
        FROM CONSENT_DATE
    ) CONSENT_MOYEAR,
    EXTRACT(
        YEAR
        FROM CONSENT_DATE
    ) CONSENT_YEAR,
    S.ON_STUDYDATE,
    EXTRACT(
        MONTH
        FROM ON_STUDYDATE
    ) ONSTUDY_MOYEAR,
    EXTRACT(
        YEAR
        FROM ON_STUDYDATE
    ) ONSTUDY_YEAR,
    S.DISEASE_SITE_DESC,
    S.SUBJECT_SUM3_DISEASE,
    S.CURRENT_STATUS SUBJECT_CURRENT_STATUS,
    S.STUDY_STATUS SUBJECT_STUDY_STATUS,
    GET_SUBJECT_STAFF_NAMES_RO(
        P.PROTOCOL_ID,
        PROTOCOL_SUBJECT_ID,
        'Consenting Physician'
    ) CONSENTING_PHYS,
    GET_SUBJECT_STAFF_NAMES_RO(
        P.PROTOCOL_ID,
        PROTOCOL_SUBJECT_ID,
        'Treating Physician'
    ) TREATING_PHYS,
    P.NCT_ID,
    P.NCI_CTRP_ID,
    P.TREATMENT_TYPE_DESC,
    P.SUMMARY4_REPORT_TYPE,
    P.PROGRAM_AREA,
    P.IIT,
    P.SPONSOR,
    P.SPONSOR_TYPE,
    P.CURRENT_STATUS PROTOCOL_CURRENT_STATUS,
    P.CURRENT_STATUS_DATE PROTOCOL_CURRENT_STATUS_DATE,
    P.BUDGET_TRACKING_NO,
    P.ACCRUAL_NOT_APPLICABLE,
    P.PI_NAME,
    P.TITLE,
    case
        when nvl(P.accrual_summary, 'N') = 'N' then S.MODIFIED_DATE
        else (
            SELECT MAX(MODIFIED_DATE)
            FROM UACC_ONCORE_PROD.SMRS_PCL_ACCRUAL_SUMMARY
            WHERE PROTOCOL_ID = P.PROTOCOL_ID
        )
    end MODIFIED_DATE
FROM ONCOREPROD..UACC_ONCORE_RW_UTILS.MYPSV2 S
    JOIN MYPV4 P ON S.PROTOCOL_ID = P.PROTOCOL_ID
    AND ON_STUDYDATE BETWEEN '01-JAN-2022' AND '31-DEC-2022'
    AND LIBRARY = 'Oncology'
    
-- SELECT TOP 10 *
-- FROM OPENQUERY(
--         ONCOREPROD,
--         'select
-- s.ACCRUAL,
-- NVL(p.accrual_summary,''N'') ACCRUAL_SUMMARY_METHOD_YN,
-- s.PROTOCOL_NO,
-- s.PROTOCOL_SUBJECT_ID,
-- s.SUBJECT_NO,
-- s.SUBJECT_MRN,
-- S.SEQUENCE_NUMBER,
-- S.BIRTH_DATE,
-- trunc((TO_DATE(INITIAL_OPEN_DATE,''MM/DD/YYYY'') - BIRTH_DATE)/365) AGE_ON_STUDY,
-- S.AGE_GROUP,
-- S.GENDER,
-- S.ETHNICITY,
-- S.RACE,
-- S.TREATING_SITE,
-- S.CONSENT_DATE,
-- EXTRACT(MONTH FROM CONSENT_DATE) CONSENT_MOYEAR,
-- EXTRACT(YEAR FROM CONSENT_DATE) CONSENT_YEAR,
-- S.ON_STUDYDATE,
-- EXTRACT(MONTH FROM ON_STUDYDATE) ONSTUDY_MOYEAR,
-- EXTRACT(YEAR FROM ON_STUDYDATE) ONSTUDY_YEAR,
-- S.DISEASE_SITE_DESC,
-- S.SUBJECT_SUM3_DISEASE,
-- S.CURRENT_STATUS SUBJECT_CURRENT_STATUS,
-- S.STUDY_STATUS SUBJECT_STUDY_STATUS,
-- GET_SUBJECT_STAFF_NAMES_RO(P.PROTOCOL_ID,PROTOCOL_SUBJECT_ID,''Consenting Physician'') CONSENTING_PHYS,
-- GET_SUBJECT_STAFF_NAMES_RO(P.PROTOCOL_ID,PROTOCOL_SUBJECT_ID,''Treating Physician'') TREATING_PHYS,
-- P.NCT_ID,
-- P.NCI_CTRP_ID,
-- P.TREATMENT_TYPE_DESC,
-- P.SUMMARY4_REPORT_TYPE,
-- P.PROGRAM_AREA,
-- P.IIT,
-- P.SPONSOR,
-- P.SPONSOR_TYPE,
-- P.CURRENT_STATUS PROTOCOL_CURRENT_STATUS,
-- P.CURRENT_STATUS_DATE PROTOCOL_CURRENT_STATUS_DATE,
-- P.BUDGET_TRACKING_NO,
-- P.ACCRUAL_NOT_APPLICABLE,
-- P.PI_NAME,
-- P.TITLE,
-- case when nvl(P.accrual_summary,''N'') = ''N'' then S.MODIFIED_DATE
-- else (SELECT MAX(MODIFIED_DATE) FROM UACC_ONCORE_PROD.SMRS_PCL_ACCRUAL_SUMMARY WHERE PROTOCOL_ID = P.PROTOCOL_ID)
-- end MODIFIED_DATE
-- FROM UACC_ONCORE_RW_UTILS.MYPSV2 S JOIN UACC_ONCORE_RW_UTILS.MYPV4 P ON S.PROTOCOL_ID = P.PROTOCOL_ID AND
-- ON_STUDYDATE BETWEEN ''01-JAN-2022'' AND ''31-DEC-2022''
-- AND LIBRARY = ''Oncology'''
--     )