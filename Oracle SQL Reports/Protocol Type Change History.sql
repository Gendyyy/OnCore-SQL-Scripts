select 

primary_key as Protocol_Id,
P.PROTOCOL_NO,
OLD_VALUE AS FROM_PROTOCOL_TYPE,
NEW_VALUE AS TO_PROTOCOL_TYPE,
TX_DATE AS CHANGE_DATE,
TX_USER AS CHANGE_MADE_BY

from uacc_oncore_prod.sv_audit_history AH
INNER JOIN uacc_oncore_prod.rv_protocol_basic P ON P.protocol_id = AH.PRIMARY_KEY
where
table_name = 'SMRS_PROTOCOL' 
and column_description = 'Protocol Type'
AND TX_DATE BETWEEN TO_DATE('2023-11-01', 'YYYY-MM-DD') AND sysdate
order by tx_date desc, primary_key