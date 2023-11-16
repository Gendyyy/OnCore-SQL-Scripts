with
    -- uacc_oncore_prod , default tables schema
    -- rv_pcl_study_site , study sites
    studysites
    as
    (
        select protocol_id,
            listagg(study_site_name,',') within group (order by study_site_name) StudySites
        from uacc_oncore_prod.rv_pcl_study_site
        group by protocol_id
    ),
    -- 
    LastNotActivePI
    as
    (
        select max(protocol_staff_role_id) staffid, protocol_id
        from uacc_oncore_prod.rv_protocol_pi_staff
        where active_pi = 'N'
        group by protocol_id
    ),
    -- contact information for the PI
    LastKnownPI
    as
    (
        select r.protocol_no, r.pi_name, r.protocol_id, r.contact_id, c.eid, c.ua_netid
        from
            uacc_oncore_prod.rv_protocol_pi_staff r, lastnotactivepi a, cv_uahs_contact c
        where r.protocol_staff_role_id = a.staffid and c.contact_id = r.contact_id

    )
--select * from lastknownpi;
,
    -- 
    PDMG
    -- primary department management group
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
        -- table backed by a job updated everyday
        --WHERE P.PROTOCOL_ID IN (SELECT PROTOCOL_ID FROM TABLE(RETURN_OSCOPROTOCOLS('07-AUG-2021','07-AUG-2021')))
    ),
    -- 
    invd
    as
    (
        select protocol_id, nvl(investigational_drug,'N') inv_drug, nvl(investigational_device,'N') inv_device
        from uacc_oncore_prod.smrs_protocol
        -- investigator initiated protocol
    ),
    -- showing history of protocol status
    cdc_q1
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        -- potocol statuses custom table
        where FROM_DATE between '01-jul-2022' and '30-sep-2022' and (THRU_DATE <= '30-SEP-2022' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    cdc_q2
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-OCT-2022' and '31-dec-2022' and (THRU_DATE <= '31-DEC-2022' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    cdc_q3
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-JAN-2023' and '31-mar-2023' and (THRU_DATE <= '31-MAR-2023' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
        -- these statuses identify as protocol closed
    ),
    -- showing history of protocol status
    cdc_q4
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-APR-2023' and '30-jun-2023' and (THRU_DATE <= '30-JUN-2023' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    pdc_q1
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-jul-2021' and '30-sep-2021' and (THRU_DATE <= '30-SEP-2021' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    pdc_q2
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-OCT-2021' and '31-dec-2021' and (THRU_DATE <= '31-DEC-2021' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    pdc_q3
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-JAN-2022' and '31-mar-2022' and (THRU_DATE <= '31-MAR-2022' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    pdc_q4
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-APR-2022' and '30-jun-2022' and (THRU_DATE <= '30-JUN-2022' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    CFY_2023
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-jul-2022' and '30-jun-2023' and (THRU_DATE <= '30-JUN-2023' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    CFY_2022
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-jul-2021' and '30-jun-2022' and (THRU_DATE <= '30-JUN-2022' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    CFY_2021
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-jul-2020' and '30-jun-2021' and (THRU_DATE <= '30-JUN-2021' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),
    -- showing history of protocol status
    CFY_2020
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from PROTOCOLSTATUS_WITHINDATE
        where FROM_DATE between '01-jul-2019' and '30-jun-2020' and (THRU_DATE <= '30-JUN-2020' OR THRU_DATE IS NULL)
            AND status in ('TERMINATED','WITHDRAWN','IRB STUDY CLOSURE','CLOSED TO ACCRUAL')
    ),


    -- 
    AFY_2023
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-JUL-2022','30-JUN-2023'))
        -- active protocols in a fiscal year
    ),
    AFY_2022
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-JUL-2021','30-JUN-2022'))
    ),
    AFY_2021
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-JUL-2020','30-JUN-2021'))
    ),
    AFY_2020
    AS
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-JUL-2019','30-JUN-2020'))
    ),
    adc_q1
    -- active during current quarter
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-jul-2022','30-sep-2022'))
    ),
    adc_q2
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-OCT-2022','31-DEC-2022'))
    ),
    adc_q3
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-JAN-2023','31-MAR-2023'))
    ),
    adc_q4
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-APR-2023','30-JUN-2023'))
    ),
    padc_q1
    -- past active during current quarter
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-jul-2021','30-sep-2021'))
    ),
    padc_q2
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-OCT-2021','31-DEC-2021'))
    ),
    padc_q3
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-JAN-2022','31-MAR-2022'))
    ),
    padc_q4
    as
    (
        select DISTINCT protocol_id, protocol_no, 1 CNT
        from table(return_oscoprotocols('01-APR-2022','30-JUN-2022'))
    )


select
    nvl(adc_q3.cnt,0) ACTIVE_DURING_CURRENT_QTR, ---- update for current quarter
    nvl(cdc_q3.cnt,0) CLOSED_DURING_CURRENT_QTR,----- update for current quarter

    p.department_name,
     1 protocol_count,
      p.protocol_id,
       p.protocol_no,
        NVL(NVL(P.pi_name, LastKnownPI.PI_NAME),'None Entered') PI_NAME,
    case when inv_drug = 'Y' and inv_device = 'N' then p.nci_tx_type || '-Investigational Drug'
    when inv_drug = 'Y' and inv_device = 'Y' then p.nci_tx_type || '-Both Investigational Drug/Device'
    when inv_drug = 'N' and inv_device = 'Y' then p.nci_tx_type || '-Investigational Device'
    else p.nci_tx_type
end  protocol_type,
    case when p.library = 'General Medicine' then
    case when p.nci_tx_type = 'Treatment' then 'Interventional'
    else
    'Non Interventional'
    end
else p.summary4_report_desc
end clinicalresearchcategory,
    case when p.library = 'Oncology' then 'UAHS-' || p.DMG else p.DMG end "Department/Primary Management Group",
    P3.AREA1 PARSED_COLLDIV,--check this the next time.
    p3.PRIMARY_DMG,
    P3.PDMG_NONE,
    --P3.RANK_DMG ONCORE_TEAM_MEMBER,
    -- 
    case when p.library = 'Oncology' then 
    (select '0721_' -- cancer center - department number
    || code
    from uacc_oncore_prod.vw_management_group m
    where m.name = p.dmg) 
else (select code
    from uacc_oncore_prod.vw_management_group m
    where m.name = p.dmg)
end dmg_code,
-- determinig the fiscal year and quarter
    case when extract(month from to_date(Initial_open_date,'mm/dd/yyyy')) between 7 and 9 then 'FY' || substr(to_char(extract(year from to_date(Initial_open_date,'mm/dd/yyyy')))+1,-4) || ' Q1'  
     when extract(month from to_date(Initial_open_date,'mm/dd/yyyy')) between 9 and 12 then 'FY' || substr(to_char(extract(year from to_date(Initial_open_date,'mm/dd/yyyy')))+1,-4) ||' Q2'
     when extract(month from to_date(Initial_open_date,'mm/dd/yyyy')) between 1 and 3 then 'FY' || substr(to_char(extract(year from to_date(Initial_open_date,'mm/dd/yyyy'))),-4) || ' Q3'
     when extract(month from to_date(Initial_open_date,'mm/dd/yyyy')) between 4 and 6 then 'FY' || substr(to_char(extract(year from to_date(Initial_open_date,'mm/dd/yyyy'))),-4) || ' Q4'
else ''
end "Newly Open in FY/QTR",

    case when extract(month from to_date(closed_date,'mm/dd/yyyy')) between 7 and 9 then 'FY' || substr(to_char(extract(year from to_date(closed_date,'mm/dd/yyyy')))+1,-4) || ' Q1'  
     when extract(month from to_date(closed_date,'mm/dd/yyyy')) between 9 and 12 then 'FY' || substr(to_char(extract(year from to_date(closed_date,'mm/dd/yyyy')))+1,-4) ||' Q2'
         when extract(month from to_date(closed_date,'mm/dd/yyyy')) between 1 and 3 then 'FY' || substr(to_char(extract(year from to_date(closed_date,'mm/dd/yyyy'))),-4) || ' Q3'
     when extract(month from to_date(closed_date,'mm/dd/yyyy')) between 4 and 6 then 'FY' || substr(to_char(extract(year from to_date(closed_date,'mm/dd/yyyy'))),-4) || ' Q4'
else ''
end "Newly Closed in FY/QTR",


    case when extract(month from to_date(study_closure_date,'mm/dd/yyyy')) between 7 and 9 then 'FY' || substr(to_char(extract(year from to_date(study_closure_date,'mm/dd/yyyy')))+1,-4) || ' Q1'  
     when extract(month from to_date(study_closure_date,'mm/dd/yyyy')) between 9 and 12 then 'FY' || substr(to_char(extract(year from to_date(study_closure_date,'mm/dd/yyyy')))+1,-4) ||' Q2'
     when extract(month from to_date(study_closure_date,'mm/dd/yyyy')) between 1 and 3 then 'FY' || substr(to_char(extract(year from to_date(study_closure_date,'mm/dd/yyyy'))),-4) || ' Q3'
     when extract(month from to_date(study_closure_date,'mm/dd/yyyy')) between 4 and 6 then 'FY' || substr(to_char(extract(year from to_date(study_closure_date,'mm/dd/yyyy'))),-4) || ' Q4'
else ''
end "Newly Concluded in FY/QTR",

    case when extract(month from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy')) between 7 and 9 then 'FY' || substr(to_char(extract(year from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy')))+1,-4) || ' Q1'  
     when extract(month from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy')) between 9 and 12 then 'FY' || substr(to_char(extract(year from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy')))+1,-4) ||' Q2'
     when extract(month from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy')) between 1 and 3 then 'FY' || substr(to_char(extract(year from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy'))),-4) || ' Q3'
     when extract(month from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy')) between 4 and 6 then 'FY' || substr(to_char(extract(year from to_date(nvl(abandoned_date,terminated_date),'mm/dd/yyyy'))),-4) || ' Q4'
else ''
end "Newly Abandoned/Terminated in FY/QTR",



    1 "Protocol Count",
    (select multi_site
    from uacc_oncore_prod.smrs_protocol
    where protocol_id = p.protocol_id) "Multi-Site Trial Y/N",

    case when p.target_accrual_upper >500 then 'Y' 
     when p.target_accrual_upper = 0 then 'Y' 
else 'N'
end Exclude,

    NVL(AFY_2023.CNT,0) "Active During FY2023", -- active protocol in general
    NVL(AFY_2022.CNT,0) "Active During FY2022",
    NVL(AFY_2021.CNT,0) "Active During FY2021",
    NVL(AFY_2020.CNT,0) "Active During FY2020",
    NVL(CFY_2023.CNT,0) "Closed During FY2023",
    NVL(CFY_2022.CNT,0) "Closed During FY2022",
    NVL(CFY_2021.CNT,0) "Closed During FY2021",
    NVL(CFY_2020.CNT,0) "Closed During FY2020",

    nvl((select 1
    from table(return_openprotocols('01-jul-2022','30-jun-2023'))
    where protocol_id = p.protocol_id),0) "Open During FY2023", -- open to accrual
    nvl((select 1
    from table(return_openprotocols('01-jul-2021','30-jun-2022'))
    where protocol_id = p.protocol_id),0) "Open During FY2022",
    nvl((select 1
    from table(return_openprotocols('01-jul-2020','30-jun-2021'))
    where protocol_id = p.protocol_id),0) "Open During FY2021",
    nvl((select 1
    from table(return_openprotocols('01-jul-2019','30-jun-2020'))
    where protocol_id = p.protocol_id),0) "Open During FY2020",

    NVL(aDC_Q1.CNT,0) ACTIVE_DURING_CURRENT_Q1, -- ADC is active during a certain quarter
    NVL(aDC_Q2.CNT,0) ACTIVE_DURING_CURRENT_Q2,
    NVL(aDC_Q3.CNT,0) ACTIVE_DURING_CURRENT_Q3,
    NVL(aDC_Q4.CNT,0) ACTIVE_DURING_CURRENT_Q4,

    NVL(PaDC_Q1.CNT,0) ACTIVE_DURING_PREVIOUS_Q1,
    NVL(PaDC_Q2.CNT,0) ACTIVE_DURING_PREVIOUS_Q2,
    NVL(PaDC_Q3.CNT,0) ACTIVE_DURING_PREVIOUS_Q3,
    NVL(PaDC_Q4.CNT,0) ACTIVE_DURING_PREVIOUS_Q4,


    NVL(CDC_Q1.CNT,0) CLOSED_DURING_CURRENT_Q1, -- CDC is inactive during a certain quarter
    NVL(CDC_Q2.CNT,0) CLOSED_DURING_CURRENT_Q2,
    NVL(CDC_Q3.CNT,0) CLOSED_DURING_CURRENT_Q3,
    NVL(CDC_Q4.CNT,0) CLOSED_DURING_CURRENT_Q4,

    NVL(PDC_Q1.CNT,0) CLOSED_DURING_PREVIOUS_Q1,
    NVL(PDC_Q2.CNT,0) CLOSED_DURING_PREVIOUS_Q2,
    NVL(PDC_Q3.CNT,0) CLOSED_DURING_PREVIOUS_Q3,
    NVL(PDC_Q4.CNT,0) CLOSED_DURING_PREVIOUS_Q4,

-- get_accrual_inst_ro3 shows the total number of enrollerments based on a protocol number and date range
-- both multiple institute but in a single site
-- all multi site protocol
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','09/30/2022', 'Both'),0) "Total Enrollment to Date Q1",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','09/30/2022', 'All'),0) "Total Enrollment to Date (including MultiSite) Q1",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','12/31/2022', 'Both'),0) "Total Enrollment to Date Q2",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','12/31/2022', 'All'),0) "Total Enrollment to Date (including MultiSite) Q2",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','04/30/2023', 'Both'),0) "Total Enrollment to Date Q3",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','04/30/2023', 'All'),0) "Total Enrollment to Date (including MultiSite) Q3",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','06/30/2023', 'Both'),0) "Total Enrollment to Date Q4",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970','06/30/2023', 'All'),0) "Total Enrollment to Date (including MultiSite) Q4",


    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970',to_char(trunc(sysdate),'mm/dd/yyyy'), 'Both'),0) "Total Enrollment to RunDate",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970',to_char(trunc(sysdate),'mm/dd/yyyy'), 'All'),0) "Total Enrollment to RunDate (including MultiSite)",

    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2022','06/30/2023', 'Both'),0) "UAHS Accrual FY2023",
    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2021','06/30/2022', 'Both'),0) "UAHS Accrual FY2022",
    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2020','06/30/2021', 'Both'),0) "UAHS Accrual FY2021",
    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2019','06/30/2020', 'Both'),0) "UAHS Accrual FY2020",

    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2023','09/30/2023', 'Both'),0) "UAHS Accrual FY2024 Q1",
    nvl(get_accrual_inst_ro3(p.protocol_id, '10/01/2023','12/31/2023', 'Both'),0) "UAHS Accrual FY2024 Q2",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/2024','03/31/2024', 'Both'),0) "UAHS Accrual FY2024 Q3",
    nvl(get_accrual_inst_ro3(p.protocol_id, '04/01/2024','06/30/2024', 'Both'),0) "UAHS Accrual FY2024 Q4",

    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2022','09/30/2022', 'Both'),0) "UAHS Accrual FY2023 Q1",
    nvl(get_accrual_inst_ro3(p.protocol_id, '10/01/2022','12/31/2022', 'Both'),0) "UAHS Accrual FY2023 Q2",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/2023','03/31/2023', 'Both'),0) "UAHS Accrual FY2023 Q3",
    nvl(get_accrual_inst_ro3(p.protocol_id, '04/01/2023','06/30/2023', 'Both'),0) "UAHS Accrual FY2023 Q4",

    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2021','09/30/2021', 'Both'),0) "UAHS Accrual FY2022 Q1",
    nvl(get_accrual_inst_ro3(p.protocol_id, '10/01/2021','12/31/2021', 'Both'),0) "UAHS Accrual FY2022 Q2",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/2022','03/31/2022', 'Both'),0) "UAHS Accrual FY2022 Q3",
    nvl(get_accrual_inst_ro3(p.protocol_id, '04/01/2022','06/30/2022', 'Both'),0) "UAHS Accrual FY2022 Q4",

    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2020','09/30/2020', 'Both'),0) "UAHS Accrual FY2021 Q1",
    nvl(get_accrual_inst_ro3(p.protocol_id, '10/01/2020','12/31/2020', 'Both'),0) "UAHS Accrual FY2021 Q2",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/2021','03/31/2021', 'Both'),0) "UAHS Accrual FY2021 Q3",
    nvl(get_accrual_inst_ro3(p.protocol_id, '04/01/2021','06/30/2021', 'Both'),0) "UAHS Accrual FY2021 Q4",

    nvl(get_accrual_inst_ro3(p.protocol_id, '07/01/2019','09/30/2019', 'Both'),0) "UAHS Accrual FY2020 Q1",
    nvl(get_accrual_inst_ro3(p.protocol_id, '10/01/2019','12/31/2019', 'Both'),0) "UAHS Accrual FY2020 Q2",
    nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/2020','03/31/2020', 'Both'),0) "UAHS Accrual FY2020 Q3",
    nvl(get_accrual_inst_ro3(p.protocol_id, '04/01/2020','06/30/2020', 'Both'),0) "UAHS Accrual FY2020 Q4",

    p.title,
    p.short_title,
    nct_id "NCT Number",
    p.title "Protocol Name",
    p.sponsor_type "Sponsor Type",
    p.budget_tracking_no,
    p.target_accrual "Accrual Target (Lower)",
    p.target_accrual_upper "Accrual Target (Upper)",
    p.study_target_accrual "Accrual Target Overall",
    current_status "Current Status",
    CURRENT_STATUS_DATE "Current Status Date",
    trunc(sysdate) - to_date(current_status_date,'mm/dd/yyyy') "Number of Days in Current Status",
    nvl(p.accrual_summary,'N') "Accrual Summary Method",

    (select multi_site
    from uacc_oncore_prod.smrs_protocol
    where protocol_id = p.protocol_id) "Multi-Site Trial Y/N",
 -- checking if we passed the target number of accruals                                                                                        
    case when nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970',to_char(trunc(sysdate),'mm/dd/yyyy'), 'Both'),0) > p.target_accrual_upper then 'Check' else 'OK' end "CheckTotal>Goal",
    -- accrual percentage against lower accrual target
    round(case when p.target_accrual = 0 then 0 else (nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970',to_char(trunc(sysdate),'mm/dd/yyyy'), 'Both'),0)/p.target_accrual)*100 end,2) lower_goal_percent,
    -- accrual percentage against upper accrual target
    round(case when p.target_accrual_upper = 0 then 0 else (nvl(get_accrual_inst_ro3(p.protocol_id, '01/01/1970',to_char(trunc(sysdate),'mm/dd/yyyy'), 'Both'),0)/p.target_accrual_upper)*100 end,2) upper_goal_percent,
    nvl(get_accrual_inst_ro3(p.protocol_id, to_char(trunc(sysdate)-90,'mm/dd/yyyy'), to_char(trunc(sysdate),'mm/dd/yyyy'),'Both'),0) "Last 90 Days",
    nvl(get_accrual_inst_ro3(p.protocol_id, to_char(trunc(sysdate)-14,'mm/dd/yyyy'), to_char(trunc(sysdate),'mm/dd/yyyy'),'Both'),0) "Last 14 Days",
    nvl(months_between(trunc(sysdate),(select max(on_studydate)
    -- custom table shows the study date and last enrollment date
    from mypsv2
    where protocol_id = p.protocol_id)),0) "Months Since Last Enrolled",
    nvl(trunc(sysdate)-(select max(on_studydate)
    from mypsv2
    where protocol_id = p.protocol_id),0) "Days Since Last Enrollment",
    p.library,
    pold.organization_unit,
    studysites "Research Study Location(s)"

from protocols p
    left join studysites s on p.protocol_id = s.protocol_id
    left join protocol_org_lib_dept pold on p.protocol_id = pold.protocol_id
    left join pdmg P3 on p.protocol_id = p3.PROTOCOL_ID
    left join invd d on p.protocol_id = d.protocol_id
    LEFT JOIN CDC_Q1 ON P.PROTOCOL_ID = CDC_Q1.PROTOCOL_ID
    LEFT JOIN CDC_Q2 ON P.PROTOCOL_ID = CDC_Q2.PROTOCOL_ID
    LEFT JOIN CDC_Q3 ON P.PROTOCOL_ID = CDC_Q3.PROTOCOL_ID
    LEFT JOIN CDC_Q4 ON P.PROTOCOL_ID = CDC_Q4.PROTOCOL_ID
    LEFT JOIN PDC_Q1 ON P.PROTOCOL_ID = PDC_Q1.PROTOCOL_ID
    LEFT JOIN PDC_Q2 ON P.PROTOCOL_ID = PDC_Q2.PROTOCOL_ID
    LEFT JOIN PDC_Q3 ON P.PROTOCOL_ID = PDC_Q3.PROTOCOL_ID
    LEFT JOIN PDC_Q4 ON P.PROTOCOL_ID = PDC_Q4.PROTOCOL_ID
    LEFT JOIN CFY_2023 ON P.PROTOCOL_ID = CFY_2023.PROTOCOL_ID
    LEFT JOIN CFY_2022 ON P.PROTOCOL_ID = CFY_2022.PROTOCOL_ID
    LEFT JOIN CFY_2021 ON P.PROTOCOL_ID = CFY_2021.PROTOCOL_ID
    LEFT JOIN CFY_2020 ON P.PROTOCOL_ID = CFY_2020.PROTOCOL_ID
    LEFT JOIN aFY_2023 ON P.PROTOCOL_ID = aFY_2023.PROTOCOL_ID
    LEFT JOIN aFY_2022 ON P.PROTOCOL_ID = aFY_2022.PROTOCOL_ID
    LEFT JOIN aFY_2021 ON P.PROTOCOL_ID = aFY_2021.PROTOCOL_ID
    LEFT JOIN aFY_2020 ON P.PROTOCOL_ID = aFY_2020.PROTOCOL_ID
    LEFT JOIN aDC_Q1 ON P.PROTOCOL_ID = adC_Q1.PROTOCOL_ID
    LEFT JOIN aDC_Q2 ON P.PROTOCOL_ID = aDC_Q2.PROTOCOL_ID
    LEFT JOIN aDC_Q3 ON P.PROTOCOL_ID = aDC_Q3.PROTOCOL_ID
    LEFT JOIN aDC_Q4 ON P.PROTOCOL_ID = aDC_Q4.PROTOCOL_ID
    LEFT JOIN PaDC_Q1 ON P.PROTOCOL_ID = PaDC_Q1.PROTOCOL_ID
    LEFT JOIN PaDC_Q2 ON P.PROTOCOL_ID = PaDC_Q2.PROTOCOL_ID
    LEFT JOIN PaDC_Q3 ON P.PROTOCOL_ID = PaDC_Q3.PROTOCOL_ID
    LEFT JOIN PaDC_Q4 ON P.PROTOCOL_ID = PaDC_Q4.PROTOCOL_ID
    LEFT JOIN LastKnownPI ON P.PROTOCOL_ID = LastKnownPI.PROTOCOL_ID
    --where p.protocol_no = '2002348365'"
