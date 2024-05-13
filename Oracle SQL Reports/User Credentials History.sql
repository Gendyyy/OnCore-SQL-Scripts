select CREDENTIAL_TYPE,
       CREDENTIAL_NUMBER,
       a.CREATED_USER,
       b.LAST_NAME || ', ' || b.FIRST_NAME as "Created User Full Name",
       a.CREATED_DATE,
       a.MODIFIED_DATE,
       a.MODIFIED_USER,
       b.LAST_NAME || ', ' || b.FIRST_NAME as "Modified User Full Name",
       EFFECTIVE_DATE,
       EXPIRATION_DATE,
       FILE_NAME
from UACC_ONCORE_PROD.rv_contact_credential a
         left join UACC_ONCORE_PROD.rv_contact b on a.CREATED_USER like b.USERNAME
where a.EMAIL_ADDRESS like 'cgalaz%'
  and lower(CREDENTIAL_TYPE) like '%citi%'
order by CREATED_DATE desc