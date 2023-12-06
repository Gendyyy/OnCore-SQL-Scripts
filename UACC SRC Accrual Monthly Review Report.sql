select --trunc(current_date,'MM') current_date,
    --last_day(current_date),
    PROTOCOL_ID,
    PROTOCOL_NO,
    PI_NAME,
    PI_EMAIL,
    INITIAL_OPEN_DATE,
    SIXMOS_ANNIVERSARY_DATE,
    ANNIVERSARY_DATE,
    NEXT_REVIEW_DATE,
    OVERALL_STUDY_GOAL,
    CC_LOWER_GOAL,
    CC_UPPER_GOAL,
    CC_ANNUAL_GOAL,
    ACCRUAL_DURATION,
    TOTAL_ACCRUAL,
    PROTOCOL_TYPE,
    TITLE,
    ACCRUALLAST12MOS,
    TO_DATE('2023-12-01', 'YYYY-MM-DD') as updated_date --    PRIMARY_DMG,
    --    ALL_DMG 
from UACC_ONCORE_RW_UTILS.src_accrual_rpt_NEW sar
WHERE (
        ANNIVERSARY_DATE >= trunc(TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'MM')
        AND ANNIVERSARY_DATE <= last_day(TO_DATE('2023-12-01', 'YYYY-MM-DD'))
    )
    or (
        sixmos_anniversary_date >= trunc(TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'MM')
        AND sixmos_anniversary_date <= last_day(TO_DATE('2023-12-01', 'YYYY-MM-DD'))
    )
    or (
        next_review_date >= trunc(TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'MM')
        AND next_review_date <= last_day(TO_DATE('2023-12-01', 'YYYY-MM-DD'))
    )