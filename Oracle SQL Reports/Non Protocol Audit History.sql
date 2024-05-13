SELECT
    PK_VALUE Key,
    TABLE_NAME,
           COLUMN_NAME,
           OLD_VALUE,
           NEW_VALUE,
           b.last_name || ', ' || b.first_name AS OperatorName,
    a.AUDIT_TIMESTAMP
--            a.*
    FROM uacc_oncore_prod.rv_table_audit_column_detail a
             INNER JOIN
         uacc_oncore_prod.rv_contact b ON b.USERNAME = a.USERNAME
    WHERE
--         LOWER(TABLE_NAME) = 'contact'
--       and
--         lower(COLUMN_NAME) like '%user%'
--         NEW_VALUE = '985'
--       AND
        (PK_VALUE = '15221');