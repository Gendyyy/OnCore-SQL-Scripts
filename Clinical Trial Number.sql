WITH
    FISCALYEAR
    AS
    (
        SELECT *
        FROM CAL_TABLE
        WHERE CAL_TYPE = 'FY' AND START_DATE BETWEEN '01-JUL-2019' AND '30-JUNE-2023'
    )
,
    invd
    as
    (
        select protocol_id, nvl(investigational_drug,'N') inv_drug, nvl(investigational_device,'N') inv_device
        from uacc_oncore_prod.smrs_protocol
    )
,
    PDMG
    AS
    (
        select PROTOCOL_ID, PROTOCOL_NO,
            case when dmg is null and (select count(*)
                from uacc_oncore_prod.sv_pcl_mgmt_mgmtgroup
                where protocol_id = p.protocol_id)>0 then 'SetPrincipal' else 'NotAssigned' end dmg2,
            CASE WHEN LIBRARY = 'Oncology' then 'UAHS-UACC' ELSE SUBSTR(DMG,1, INSTR(DMG,'-',1)-1) END AREA1,
            SUBSTR(DMG,INSTR(DMG,'-',1)+1,LENGTH(DMG)-INSTR(DMG,'-',1))PDMG_NONE1,
            case when p.library = 'Oncology' then 'UAHS'
        ELSE
            
            CASE WHEN DMG LIKE 'COMP%' THEN 'COMP'
                WHEN DMG LIKE 'COMT%' THEN 'COMT'
                WHEN DMG LIKE 'UAHS%' THEN 'UAHS'
            ELSE 'OTHER'
            END
        END area,
            DMG,
            LIBRARY,
            case when p.library = 'Oncology' then DMG
        ELSE
            --SUBSTR(DMG,6,100)
            SUBSTR(DMG,INSTR(DMG,'-',1)+1,LENGTH(DMG)-INSTR(DMG,'-',1))
        END PRIMARY_DMG,
            nvl(substr(regexp_replace(
         case when p.library = 'Oncology' then DMG
         ELSE
            CASE WHEN DMG LIKE 'COMP%' THEN SUBSTR(DMG,6,100)
                 WHEN DMG LIKE 'COMT%' THEN SUBSTR(DMG,6,100)
                 WHEN DMG LIKE 'UAHS%' THEN SUBSTR(DMG,6,100)
            ELSE DMG
            END
        END 
         , '[]~!@#$%^&*()_+=\{}( )[:�;�<,>./?]+',  ''),1,29),
         'Unknown') PDMG_NONE,
            nvl(accrual_summary,'N') accrual_summary


        from protocols p
    )
,
    StatusList
    AS
    (
                                                                                                                                                                                                                                    SELECT 'Open' STATUS, 2020 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OPENPROTOCOLS('01-JUL-2019','30-JUN-2020'))
        UNION ALL
            SELECT 'Open' STATUS, 2021 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OPENPROTOCOLS('01-JUL-2020','30-JUN-2021'))
        UNION ALL
            SELECT 'Open' STATUS, 2022 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OPENPROTOCOLS('01-JUL-2021','30-JUN-2022'))
        UNION ALL
            SELECT 'Open' STATUS, 2023 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OPENPROTOCOLS('01-JUL-2022','30-JUN-2023'))
        UNION ALL
            SELECT 'Newly Open' status, 2020 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where initial_open_date  BETWEEN '01-JUL-2019' AND '30-JUN-2020'
        UNION ALL
            SELECT 'Newly Open' status, 2021 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where initial_open_date  BETWEEN '01-JUL-2020' AND '30-JUN-2021'
        UNION ALL
            SELECT 'Newly Open' status, 2022 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where initial_open_date  BETWEEN '01-JUL-2021' AND '30-JUN-2022'
        UNION ALL
            SELECT 'Newly Open' status, 2023 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where initial_open_date  BETWEEN '01-JUL-2022' AND '30-JUN-2023'
        UNION ALL
            SELECT 'Active' STATUS, 2020 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OSCOPROTOCOLS('01-JUL-2019','30-JUN-2020'))
        UNION ALL
            SELECT 'Active' STATUS, 2021 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OSCOPROTOCOLS('01-JUL-2020','30-JUN-2021'))
        UNION ALL
            SELECT 'Active' STATUS, 2022 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OSCOPROTOCOLS('01-JUL-2021','30-JUN-2022'))
        UNION ALL
            SELECT 'Active' STATUS, 2023 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM TABLE(RETURN_OSCOPROTOCOLS('01-JUL-2022','30-JUN-2023'))
        UNION ALL
            select 'Closed' STATUS, 2020 FY, protocol_id, protocol_no
            from PROTOCOLSTATUS_WITHINDATE
            where FROM_DATE between '01-jul-2019' and '30-jun-2020' and (THRU_DATE <= '30-JUN-2020' OR THRU_DATE IS NULL)
                AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
            GROUP BY PROTOCOL_ID, PROTOCOL_NO
        UNION ALL
            select 'Closed' STATUS, 2021 FY, protocol_id, protocol_no
            from PROTOCOLSTATUS_WITHINDATE
            where FROM_DATE between '01-jul-2020' and '30-jun-2021' and (THRU_DATE <= '30-JUN-2020' OR THRU_DATE IS NULL)
                AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
            GROUP BY PROTOCOL_ID, PROTOCOL_NO
        UNION ALL
            select 'Closed' STATUS, 2022 FY, protocol_id, protocol_no
            from PROTOCOLSTATUS_WITHINDATE
            where FROM_DATE between '01-jul-2021' and '30-jun-2022' and (THRU_DATE <= '30-JUN-2020' OR THRU_DATE IS NULL)
                AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
            GROUP BY PROTOCOL_ID, PROTOCOL_NO
        UNION ALL
            select 'Closed' STATUS, 2023 FY, protocol_id, protocol_no
            from PROTOCOLSTATUS_WITHINDATE
            where FROM_DATE between '01-jul-2022' and '30-jun-2023' and (THRU_DATE <= '30-JUN-2020' OR THRU_DATE IS NULL)
                AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
            GROUP BY PROTOCOL_ID, PROTOCOL_NO
        UNION ALL
            SELECT 'Newly Closed' status, 2020 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where closed_date  BETWEEN '01-JUL-2019' AND '30-JUN-2020'
        UNION ALL
            SELECT 'Newly Closed' status, 2021 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where closed_date  BETWEEN '01-JUL-2020' AND '30-JUN-2021'
        UNION ALL
            SELECT 'Newly Closed' status, 2022 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where closed_date  BETWEEN '01-JUL-2021' AND '30-JUN-2022'
        UNION ALL
            SELECT 'Newly Closed' status, 2023 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where closed_date  BETWEEN '01-JUL-2022' AND '30-JUN-2023'
        UNION ALL
            SELECT 'Newly Concluded' status, 2020 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2019' AND '30-JUN-2020'
        UNION ALL
            SELECT 'Newly Concluded' status, 2021 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2020' AND '30-JUN-2021'
        UNION ALL
            SELECT 'Newly Concluded' status, 2022 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2021' AND '30-JUN-2022'
        UNION ALL
            SELECT 'Newly Concluded' status, 2023 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2022' AND '30-JUN-2023'
        UNION ALL
            SELECT 'Newly Abandoned/Terminated' status, 2020 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2019' AND '30-JUN-2020'
        UNION ALL
            SELECT 'Newly Abandoned/Terminated' status, 2021 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2020' AND '30-JUN-2021'
        UNION ALL
            SELECT 'Newly Abandoned/Terminated' status, 2022 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2021' AND '30-JUN-2022'
        UNION ALL
            SELECT 'Newly Abandoned/Terminated' status, 2023 FY, PROTOCOL_ID, PROTOCOL_NO
            FROM protocols
            where study_closure_date  BETWEEN '01-JUL-2022' AND '30-JUN-2023'
    )
SELECT
    P.PI_NAME,
    p.title,
    P3.AREA1 PARSED_COLLDIV,--check this the next time.
    p3.PRIMARY_DMG "Department/Primary Management Group",
    P.LIBRARY,
    P.PROTOCOL_NO,
    sl.protocol_no status_protocol_no,
    SL.FY FISCAL_YEAR,
    1 PROTOCOL_COUNT,
    nvl(get_accrual_inst_ro3(p.protocol_id, FY.STRSTART_DATE,FY.STREND_DATE, 'Both'),0) ENROLLMENT,
    SL.STATUS,
    case when inv_drug = 'Y' and inv_device = 'N' then p.nci_tx_type || '-Investigational Drug'
    when inv_drug = 'Y' and inv_device = 'Y' then p.nci_tx_type || '-Both Investigational Drug/Device'
    when inv_drug = 'N' and inv_device = 'Y' then p.nci_tx_type || '-Investigational Device'
    else p.nci_tx_type
end  protocol_type,
    CASE WHEN p.LIBRARY = 'General Medicine' then
    case when p.nci_tx_type = 'Treatment' then 'Interventional'
    else 'Non-Interventional'
    end 
else 
summary4_report_desc 
end clinicalresearchcategory
FROM STATUSLIST SL
    LEFT JOIN PROTOCOLS P ON SL.PROTOCOL_ID = P.PROTOCOL_ID
    LEFT JOIN PDMG P3 ON P.PROTOCOL_ID = P3.PROTOCOL_ID
    LEFT JOIN FISCALYEAR FY ON SL.FY = FY.CAL_DESC
    LEFT JOIN INVD I ON I.PROTOCOL_ID = P.PROTOCOL_ID
where p.protocol_no is not null
