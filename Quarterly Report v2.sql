WITH studysites
     AS (SELECT protocol_id,
                Listagg(study_site_name, ',')
                  within GROUP (ORDER BY study_site_name) StudySites
         FROM   uacc_oncore_prod.rv_pcl_study_site
         GROUP  BY protocol_id),
     lastnotactivepi
     AS (SELECT Max(protocol_staff_role_id) staffid,
                protocol_id
         FROM   uacc_oncore_prod.rv_protocol_pi_staff
         WHERE  active_pi = 'N'
         GROUP  BY protocol_id),
     lastknownpi
     AS (SELECT r.protocol_no,
                r.pi_name,
                r.protocol_id,
                r.contact_id,
                c.eid,
                c.ua_netid
         FROM   uacc_oncore_prod.rv_protocol_pi_staff r,
                lastnotactivepi a,
                cv_uahs_contact c
         WHERE  r.protocol_staff_role_id = a.staffid
                AND c.contact_id = r.contact_id)
--select * from lastknownpi;
,
     pdmg
     AS (SELECT protocol_id,
                protocol_no,
                CASE
                  WHEN dmg IS NULL
                       AND (SELECT Count(*)
                            FROM   uacc_oncore_prod.sv_pcl_mgmt_mgmtgroup
                            WHERE  protocol_id = p.protocol_id) > 0 THEN
                  'SetPrincipal'
                  ELSE 'NotAssigned'
                END
                   dmg2,
                CASE
                  WHEN library = 'Oncology' THEN 'UAHS-UACC'
                  ELSE Substr(dmg, 1, Instr(dmg, '-', 1) - 1)
                END
                   AREA1,
                Substr(dmg, Instr(dmg, '-', 1) + 1, Length(dmg) - Instr(dmg, '-'
                                                                  , 1))
                   PDMG_NONE1,
                CASE
                  WHEN p.library = 'Oncology' THEN 'UAHS'
                  ELSE
                    CASE
                      WHEN dmg LIKE 'COMP%' THEN 'COMP'
                      WHEN dmg LIKE 'COMT%' THEN 'COMT'
                      WHEN dmg LIKE 'UAHS%' THEN 'UAHS'
                      ELSE 'OTHER'
                    END
                END
                   area,
                dmg,
                library,
                CASE
                  WHEN p.library = 'Oncology' THEN dmg
                  ELSE
                --SUBSTR(DMG,6,100)
                Substr(dmg, Instr(dmg, '-', 1) + 1, Length(dmg) - Instr(dmg, '-'
                                                                  , 1))
                END
                   PRIMARY_DMG,
                Nvl(Substr(Regexp_replace(CASE
                                            WHEN p.library = 'Oncology' THEN dmg
                                            ELSE
                                              CASE
                                                WHEN dmg LIKE 'COMP%' THEN
                                                Substr(dmg, 6, 100)
                                                WHEN dmg LIKE 'COMT%' THEN
                                                Substr(dmg, 6, 100)
                                                WHEN dmg LIKE 'UAHS%' THEN
                                                Substr(dmg, 6, 100)
                                                ELSE dmg
                                              END
                                          END,
                           '[]~!@#$%^&*()_+=\{}( )[:”;’<,>./?]+'
                           , ''), 1
                    , 29
                    ), 'Unknown')
                   PDMG_NONE,
                Nvl(accrual_summary, 'N')
                   accrual_summary
         FROM   protocols p
        --WHERE P.PROTOCOL_ID IN (SELECT PROTOCOL_ID FROM TABLE(RETURN_OSCOPROTOCOLS('07-AUG-2021','07-AUG-2021')))
        ),
     invd
     AS (SELECT protocol_id,
                Nvl(investigational_drug, 'N')   inv_drug,
                Nvl(investigational_device, 'N') inv_device
         FROM   uacc_oncore_prod.smrs_protocol),
     cdc_q1
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-jul-2023' AND '30-sep-2023'
                AND ( thru_date <= '30-SEP-2023'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     cdc_q2
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-OCT-2023' AND '31-dec-2023'
                AND ( thru_date <= '31-DEC-2023'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     cdc_q3
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-JAN-2024' AND '31-mar-2024'
                AND ( thru_date <= '31-MAR-2024'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     cdc_q4
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-APR-2024' AND '30-jun-2024'
                AND ( thru_date <= '30-JUN-2024'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     pdc_q1
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-jul-2022' AND '30-sep-2022'
                AND ( thru_date <= '30-SEP-2022'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     pdc_q2
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-OCT-2022' AND '31-dec-2022'
                AND ( thru_date <= '31-DEC-2022'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     pdc_q3
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-JAN-2023' AND '31-mar-2023'
                AND ( thru_date <= '31-MAR-2023'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     pdc_q4
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-APR-2023' AND '30-jun-2023'
                AND ( thru_date <= '30-JUN-2023'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     cfy_2024
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-jul-2023' AND '30-jun-2024'
                AND ( thru_date <= '30-JUN-2024'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     cfy_2023
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-jul-2022' AND '30-jun-2023'
                AND ( thru_date <= '30-JUN-2023'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     cfy_2022
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-jul-2021' AND '30-jun-2022'
                AND ( thru_date <= '30-JUN-2022'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     cfy_2021
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   protocolstatus_withindate
         WHERE  from_date BETWEEN '01-jul-2020' AND '30-jun-2021'
                AND ( thru_date <= '30-JUN-2021'
                       OR thru_date IS NULL )
                AND status IN ( 'TERMINATED', 'WITHDRAWN', 'IRB STUDY CLOSURE',
                                'CLOSED TO ACCRUAL'
                              )),
     afy_2024
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-JUL-2023', '30-JUN-2024'))),
     afy_2023
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-JUL-2022', '30-JUN-2023'))),
     afy_2022
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-JUL-2021', '30-JUN-2022'))),
     afy_2021
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-JUL-2020', '30-JUN-2021'))),
     adc_q1
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-jul-2023', '30-sep-2023'))),
     adc_q2
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-OCT-2023', '31-DEC-2023'))),
     adc_q3
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-JAN-2024', '31-MAR-2024'))),
     adc_q4
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-APR-2024', '30-JUN-2024'))),
     padc_q1
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-jul-2022', '30-sep-2022'))),
     padc_q2
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-OCT-2022', '31-DEC-2022'))),
     padc_q3
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-JAN-2023', '31-MAR-2023'))),
     padc_q4
     AS (SELECT DISTINCT protocol_id,
                         protocol_no,
                         1 CNT
         FROM   TABLE(Return_oscoprotocols('01-APR-2023', '30-JUN-2023')))
SELECT Nvl(adc_q3.cnt, 0)
       ACTIVE_DURING_CURRENT_QTR,---- update for current quarter
       Nvl(cdc_q3.cnt, 0)
       CLOSED_DURING_CURRENT_QTR,----- update for current quarter
       p.department_name,
       1                                                          protocol_count
       ,
       p.protocol_id,
       p.protocol_no,
       Nvl(Nvl(P.pi_name, lastknownpi.pi_name), 'None Entered')   PI_NAME,
       CASE
         WHEN inv_drug = 'Y'
              AND inv_device = 'N' THEN p.nci_tx_type
                                        || '-Investigational Drug'
         WHEN inv_drug = 'Y'
              AND inv_device = 'Y' THEN p.nci_tx_type
                                        || '-Both Investigational Drug/Device'
         WHEN inv_drug = 'N'
              AND inv_device = 'Y' THEN p.nci_tx_type
                                        || '-Investigational Device'
         ELSE p.nci_tx_type
       END                                                        protocol_type,
       CASE
         WHEN p.library = 'General Medicine' THEN
           CASE
             WHEN p.nci_tx_type = 'Treatment' THEN 'Interventional'
             ELSE 'Non Interventional'
           END
         ELSE p.summary4_report_desc
       END
       clinicalresearchcategory,
       CASE
         WHEN p.library = 'Oncology' THEN 'UAHS-'
                                          || p.dmg
         ELSE p.dmg
       END
       "Department/Primary Management Group",
       P3.area1                                                   PARSED_COLLDIV
       ,--check this the next time.
       p3.primary_dmg,
       P3.pdmg_none,
       --P3.RANK_DMG ONCORE_TEAM_MEMBER,
       CASE
         WHEN p.library = 'Oncology' THEN (SELECT '0721_'
                                                  ||code
                                           FROM
         uacc_oncore_prod.vw_management_group m
                                           WHERE  m.name = p.dmg)
         ELSE (SELECT code
               FROM   uacc_oncore_prod.vw_management_group m
               WHERE  m.name = p.dmg)
       END                                                        dmg_code,
       CASE
         WHEN Extract(month FROM To_date(initial_open_date, 'mm/dd/yyyy'))
              BETWEEN 7
              AND 9 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(initial_open_date,
                 'mm/dd/yyyy')))
                 + 1, -4)
       || ' Q1'
         WHEN Extract(month FROM To_date(initial_open_date, 'mm/dd/yyyy'))
              BETWEEN 9
              AND 12 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(initial_open_date,
                 'mm/dd/yyyy')))
                 + 1, -4)
       ||' Q2'
         WHEN Extract(month FROM To_date(initial_open_date, 'mm/dd/yyyy'))
              BETWEEN 1
              AND 3 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(initial_open_date,
                                           'mm/dd/yyyy'))),
          -4)
       || ' Q3'
         WHEN Extract(month FROM To_date(initial_open_date, 'mm/dd/yyyy'))
              BETWEEN 4
              AND 6 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(initial_open_date,
                                           'mm/dd/yyyy'))),
          -4)
       || ' Q4'
         ELSE ''
       END
       "Newly Open in FY/QTR",
       CASE
         WHEN Extract(month FROM To_date(closed_date, 'mm/dd/yyyy')) BETWEEN 7
              AND 9
       THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(closed_date, 'mm/dd/yyyy')))
                 + 1, -4)
       || ' Q1'
         WHEN Extract(month FROM To_date(closed_date, 'mm/dd/yyyy')) BETWEEN 9
              AND 12
       THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(closed_date, 'mm/dd/yyyy')))
                 + 1, -4)
       ||' Q2'
         WHEN Extract(month FROM To_date(closed_date, 'mm/dd/yyyy')) BETWEEN 1
              AND 3
       THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(closed_date, 'mm/dd/yyyy'))),
          -4)
       || ' Q3'
         WHEN Extract(month FROM To_date(closed_date, 'mm/dd/yyyy')) BETWEEN 4
              AND 6
       THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(closed_date, 'mm/dd/yyyy'))),
          -4)
       || ' Q4'
         ELSE ''
       END
       "Newly Closed in FY/QTR",
       CASE
         WHEN Extract(month FROM To_date(study_closure_date, 'mm/dd/yyyy'))
              BETWEEN 7
              AND 9 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(study_closure_date,
                 'mm/dd/yyyy')))
                 + 1, -4)
       || ' Q1'
         WHEN Extract(month FROM To_date(study_closure_date, 'mm/dd/yyyy'))
              BETWEEN 9
              AND 12 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(study_closure_date,
                 'mm/dd/yyyy')))
                 + 1, -4)
       ||' Q2'
         WHEN Extract(month FROM To_date(study_closure_date, 'mm/dd/yyyy'))
              BETWEEN 1
              AND 3 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(study_closure_date,
                                           'mm/dd/yyyy'))),
          -4
          )
       || ' Q3'
         WHEN Extract(month FROM To_date(study_closure_date, 'mm/dd/yyyy'))
              BETWEEN 4
              AND 6 THEN 'FY'
       || Substr(To_char(Extract(year FROM To_date(study_closure_date,
                                           'mm/dd/yyyy'))),
          -4
          )
       || ' Q4'
         ELSE ''
       END
       "Newly Concluded in FY/QTR",
       CASE
         WHEN Extract(month FROM To_date(Nvl(abandoned_date, terminated_date),
                                 'mm/dd/yyyy'))
              BETWEEN 7 AND 9 THEN 'FY'
                                   || Substr(To_char(Extract(year FROM To_date(
                                             Nvl(
                                             abandoned_date, terminated_date)
                                             ,
                                                'mm/dd/yyyy')))
                                             + 1, -4)
                                   || ' Q1'
         WHEN Extract(month FROM To_date(Nvl(abandoned_date, terminated_date),
                                 'mm/dd/yyyy'))
              BETWEEN 9 AND 12 THEN 'FY'
                                    || Substr(To_char(Extract(year FROM To_date(
                                              Nvl(
                                              abandoned_date, terminated_date)
                                              ,
                                                 'mm/dd/yyyy')))
                                              + 1, -4)
                                    ||' Q2'
         WHEN Extract(month FROM To_date(Nvl(abandoned_date, terminated_date),
                                 'mm/dd/yyyy'))
              BETWEEN 1 AND 3 THEN 'FY'
                                   || Substr(To_char(Extract(year FROM To_date(
                                             Nvl(
                                                       abandoned_date,
                                                       terminated_date)
                                                       ,
                                                       'mm/dd/yyyy'))),
                                      -4)
                                   || ' Q3'
         WHEN Extract(month FROM To_date(Nvl(abandoned_date, terminated_date),
                                 'mm/dd/yyyy'))
              BETWEEN 4 AND 6 THEN 'FY'
                                   || Substr(To_char(Extract(year FROM To_date(
                                             Nvl(
                                                       abandoned_date,
                                                       terminated_date)
                                                       ,
                                                       'mm/dd/yyyy'))),
                                      -4)
                                   || ' Q4'
         ELSE ''
       END
       "Newly Abandoned/Terminated in FY/QTR",
       1
       "Protocol Count",
       (SELECT multi_site
        FROM   uacc_oncore_prod.smrs_protocol
        WHERE  protocol_id = p.protocol_id)
       "Multi-Site Trial Y/N",
       CASE
         WHEN p.target_accrual_upper > 500 THEN 'Y'
         WHEN p.target_accrual_upper = 0 THEN 'Y'
         ELSE 'N'
       END                                                        Exclude,
       /*nvl((select 1 from table(return_oscoprotocols('01-jul-2022','30-jun-2023')) where protocol_id = p.protocol_id),0) "Active During FY2023",
       
       nvl((select 1 from table(return_oscoprotocols('01-jul-2021','30-jun-2022')) where protocol_id = p.protocol_id),0) "Active During FY2022",
       
       nvl((select 1 from table(return_oscoprotocols('01-jul-2020','30-jun-2021')) where protocol_id = p.protocol_id),0) "Active During FY2021",
       
       nvl((select 1 from table(return_oscoprotocols('01-jul-2019','30-jun-2020')) where protocol_id = p.protocol_id),0) "Active During FY2020",
       
       */
       Nvl(afy_2024.cnt, 0)
       "Active During FY2024",
       Nvl(afy_2023.cnt, 0)
       "Active During FY2023",
       Nvl(afy_2022.cnt, 0)
       "Active During FY2022",
       Nvl(afy_2021.cnt, 0)
       "Active During FY2021",
       /*nvl((select 1 from table(return_citw_protocols('01-jul-2022','30-jun-2023')) where protocol_id = p.protocol_id),0) "Closed During FY2023",
       
       nvl((select 1 from table(return_citw_protocols('01-jul-2021','30-jun-2022')) where protocol_id = p.protocol_id),0) "Closed During FY2022",
       
       nvl((select 1 from table(return_citw_protocols('01-jul-2020','30-jun-2021')) where protocol_id = p.protocol_id),0) "Closed During FY2021",
       
       nvl((select 1 from table(return_citw_protocols('01-jul-2019','30-jun-2020')) where protocol_id = p.protocol_id),0) "Closed During FY2020",
       
       */
       Nvl(cfy_2024.cnt, 0)
       "Closed During FY2024",
       Nvl(cfy_2023.cnt, 0)
       "Closed During FY2023",
       Nvl(cfy_2022.cnt, 0)
       "Closed During FY2022",
       Nvl(cfy_2021.cnt, 0)
       "Closed During FY2021",
       Nvl((SELECT 1
            FROM   TABLE(Return_openprotocols('01-jul-2023', '30-jun-2024'))
            WHERE  protocol_id = p.protocol_id), 0)
       "Open During FY2024",
       Nvl((SELECT 1
            FROM   TABLE(Return_openprotocols('01-jul-2022', '30-jun-2023'))
            WHERE  protocol_id = p.protocol_id), 0)
       "Open During FY2023",
       Nvl((SELECT 1
            FROM   TABLE(Return_openprotocols('01-jul-2021', '30-jun-2022'))
            WHERE  protocol_id = p.protocol_id), 0)
       "Open During FY2022",
       Nvl((SELECT 1
            FROM   TABLE(Return_openprotocols('01-jul-2020', '30-jun-2021'))
            WHERE  protocol_id = p.protocol_id), 0)
       "Open During FY2021",
       Nvl(adc_q1.cnt, 0)
       ACTIVE_DURING_CURRENT_Q1,
       Nvl(adc_q2.cnt, 0)
       ACTIVE_DURING_CURRENT_Q2,
       Nvl(adc_q3.cnt, 0)
       ACTIVE_DURING_CURRENT_Q3,
       Nvl(adc_q4.cnt, 0)
       ACTIVE_DURING_CURRENT_Q4,
       Nvl(padc_q1.cnt, 0)
       ACTIVE_DURING_PREVIOUS_Q1,
       Nvl(padc_q2.cnt, 0)
       ACTIVE_DURING_PREVIOUS_Q2,
       Nvl(padc_q3.cnt, 0)
       ACTIVE_DURING_PREVIOUS_Q3,
       Nvl(padc_q4.cnt, 0)
       ACTIVE_DURING_PREVIOUS_Q4,
       Nvl(cdc_q1.cnt, 0)
       CLOSED_DURING_CURRENT_Q1,
       Nvl(cdc_q2.cnt, 0)
       CLOSED_DURING_CURRENT_Q2,
       Nvl(cdc_q3.cnt, 0)
       CLOSED_DURING_CURRENT_Q3,
       Nvl(cdc_q4.cnt, 0)
       CLOSED_DURING_CURRENT_Q4,
       Nvl(pdc_q1.cnt, 0)
       CLOSED_DURING_PREVIOUS_Q1,
       Nvl(pdc_q2.cnt, 0)
       CLOSED_DURING_PREVIOUS_Q2,
       Nvl(pdc_q3.cnt, 0)
       CLOSED_DURING_PREVIOUS_Q3,
       Nvl(pdc_q4.cnt, 0)
       CLOSED_DURING_PREVIOUS_Q4,
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '09/30/2023',
           'Both'), 0)
       "Total Enrollment to Date Q1",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '09/30/2023', 'All'
           ), 0)
       "Total Enrollment to Date (including MultiSite) Q1",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '12/31/2023',
           'Both'), 0)
       "Total Enrollment to Date Q2",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '12/31/2023', 'All'
           ), 0)
       "Total Enrollment to Date (including MultiSite) Q2",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '04/30/2024',
           'Both'), 0)
       "Total Enrollment to Date Q3",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '04/30/2024', 'All'
           ), 0)
       "Total Enrollment to Date (including MultiSite) Q3",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '06/30/2024',
           'Both'), 0)
       "Total Enrollment to Date Q4",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970', '06/30/2024', 'All'
           ), 0)
       "Total Enrollment to Date (including MultiSite) Q4",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970',
               To_char(Trunc(SYSDATE), 'mm/dd/yyyy'), 'Both'), 0)
       "Total Enrollment to RunDate",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970',
               To_char(Trunc(SYSDATE), 'mm/dd/yyyy'), 'All'), 0)
       "Total Enrollment to RunDate (including MultiSite)",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2023', '06/30/2024',
           'Both'), 0)
       "UAHS Accrual FY2024",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2022', '06/30/2023',
           'Both'), 0)
       "UAHS Accrual FY2023",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2021', '06/30/2022',
           'Both'), 0)
       "UAHS Accrual FY2022",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2020', '06/30/2021',
           'Both'), 0)
       "UAHS Accrual FY2021",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2023', '09/30/2023',
           'Both'), 0)
       "UAHS Accrual FY2024 Q1",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '10/01/2023', '12/31/2023',
           'Both'), 0)
       "UAHS Accrual FY2024 Q2",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/2024', '03/31/2024',
           'Both'), 0)
       "UAHS Accrual FY2024 Q3",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '04/01/2024', '06/30/2024',
           'Both'), 0)
       "UAHS Accrual FY2024 Q4",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2022', '09/30/2022',
           'Both'), 0)
       "UAHS Accrual FY2023 Q1",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '10/01/2022', '12/31/2022',
           'Both'), 0)
       "UAHS Accrual FY2023 Q2",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/2023', '03/31/2023',
           'Both'), 0)
       "UAHS Accrual FY2023 Q3",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '04/01/2023', '06/30/2023',
           'Both'), 0)
       "UAHS Accrual FY2023 Q4",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2021', '09/30/2021',
           'Both'), 0)
       "UAHS Accrual FY2022 Q1",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '10/01/2021', '12/31/2021',
           'Both'), 0)
       "UAHS Accrual FY2022 Q2",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/2022', '03/31/2022',
           'Both'), 0)
       "UAHS Accrual FY2022 Q3",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '04/01/2022', '06/30/2022',
           'Both'), 0)
       "UAHS Accrual FY2022 Q4",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2020', '09/30/2020',
           'Both'), 0)
       "UAHS Accrual FY2021 Q1",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '10/01/2020', '12/31/2020',
           'Both'), 0)
       "UAHS Accrual FY2021 Q2",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/2021', '03/31/2021',
           'Both'), 0)
       "UAHS Accrual FY2021 Q3",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '04/01/2021', '06/30/2021',
           'Both'), 0)
       "UAHS Accrual FY2021 Q4",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '07/01/2019', '09/30/2019',
           'Both'), 0)
       "UAHS Accrual FY2020 Q1",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '10/01/2019', '12/31/2019',
           'Both'), 0)
       "UAHS Accrual FY2020 Q2",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/2020', '03/31/2020',
           'Both'), 0)
       "UAHS Accrual FY2020 Q3",
       Nvl(Get_accrual_inst_ro3(p.protocol_id, '04/01/2020', '06/30/2020',
           'Both'), 0)
       "UAHS Accrual FY2020 Q4",
       p.title,
       p.short_title,
       nct_id                                                     "NCT Number",
       p.title
       "Protocol Name",
       p.sponsor_type                                             "Sponsor Type"
       ,
       p.budget_tracking_no,
       p.target_accrual
       "Accrual Target (Lower)",
       p.target_accrual_upper
       "Accrual Target (Upper)",
       p.study_target_accrual
       "Accrual Target Overall",
       current_status
       "Current Status",
       current_status_date
       "Current Status Date",
       Trunc(SYSDATE) - To_date(current_status_date, 'mm/dd/yyyy')
       "Number of Days in Current Status",
       Nvl(p.accrual_summary, 'N')
       "Accrual Summary Method",
       (SELECT multi_site
        FROM   uacc_oncore_prod.smrs_protocol
        WHERE  protocol_id = p.protocol_id)
       "Multi-Site Trial Y/N",
       CASE
         WHEN Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970',
                             To_char(Trunc(SYSDATE), 'mm/dd/yyyy'), 'Both'), 0)
              >
              p.target_accrual_upper THEN 'Check'
         ELSE 'OK'
       END
       "CheckTotal>Goal",
       Round(CASE
               WHEN p.target_accrual = 0 THEN 0
               ELSE ( Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970',
                                       To_char(Trunc(SYSDATE), 'mm/dd/yyyy'),
                             'Both'), 0) / p.target_accrual ) * 100
             END, 2)
       lower_goal_percent,
       Round(CASE
               WHEN p.target_accrual_upper = 0 THEN 0
               ELSE ( Nvl(Get_accrual_inst_ro3(p.protocol_id, '01/01/1970',
                                       To_char(Trunc(SYSDATE), 'mm/dd/yyyy'),
                             'Both'), 0) / p.target_accrual_upper ) * 100
             END, 2)
       upper_goal_percent,
       Nvl(Get_accrual_inst_ro3(p.protocol_id,
           To_char(Trunc(SYSDATE) - 90, 'mm/dd/yyyy'),
               To_char(Trunc(SYSDATE), 'mm/dd/yyyy'), 'Both'), 0) "Last 90 Days"
       ,
       Nvl(Get_accrual_inst_ro3(p.protocol_id,
           To_char(Trunc(SYSDATE) - 14, 'mm/dd/yyyy'),
               To_char(Trunc(SYSDATE), 'mm/dd/yyyy'), 'Both'), 0) "Last 14 Days"
       ,
       Nvl(Months_between(Trunc(SYSDATE), (SELECT Max(on_studydate)
                                           FROM   mypsv2
                                           WHERE  protocol_id =
       p.protocol_id)), 0)
         "Months Since Last Enrolled",
       Nvl(Trunc(SYSDATE) - (SELECT Max(on_studydate)
                             FROM   mypsv2
                             WHERE  protocol_id = p.protocol_id), 0)
       "Days Since Last Enrollment",
       p.library,
       pold.organization_unit,
       studysites
       "Research Study Location(s)"
FROM   protocols p
       left join studysites s
              ON p.protocol_id = s.protocol_id
       left join protocol_org_lib_dept pold
              ON p.protocol_id = pold.protocol_id
       left join pdmg P3
              ON p.protocol_id = p3.protocol_id
       left join invd d
              ON p.protocol_id = d.protocol_id
       left join cdc_q1
              ON P.protocol_id = cdc_q1.protocol_id
       left join cdc_q2
              ON P.protocol_id = cdc_q2.protocol_id
       left join cdc_q3
              ON P.protocol_id = cdc_q3.protocol_id
       left join cdc_q4
              ON P.protocol_id = cdc_q4.protocol_id
       left join pdc_q1
              ON P.protocol_id = pdc_q1.protocol_id
       left join pdc_q2
              ON P.protocol_id = pdc_q2.protocol_id
       left join pdc_q3
              ON P.protocol_id = pdc_q3.protocol_id
       left join pdc_q4
              ON P.protocol_id = pdc_q4.protocol_id
       left join cfy_2024
              ON P.protocol_id = cfy_2024.protocol_id
       left join cfy_2023
              ON P.protocol_id = cfy_2023.protocol_id
       left join cfy_2022
              ON P.protocol_id = cfy_2022.protocol_id
       left join cfy_2021
              ON P.protocol_id = cfy_2021.protocol_id
       left join afy_2024
              ON P.protocol_id = afy_2024.protocol_id
       left join afy_2023
              ON P.protocol_id = afy_2023.protocol_id
       left join afy_2022
              ON P.protocol_id = afy_2022.protocol_id
       left join afy_2021
              ON P.protocol_id = afy_2021.protocol_id
       left join adc_q1
              ON P.protocol_id = adc_q1.protocol_id
       left join adc_q2
              ON P.protocol_id = adc_q2.protocol_id
       left join adc_q3
              ON P.protocol_id = adc_q3.protocol_id
       left join adc_q4
              ON P.protocol_id = adc_q4.protocol_id
       left join padc_q1
              ON P.protocol_id = padc_q1.protocol_id
       left join padc_q2
              ON P.protocol_id = padc_q2.protocol_id
       left join padc_q3
              ON P.protocol_id = padc_q3.protocol_id
       left join padc_q4
              ON P.protocol_id = padc_q4.protocol_id
       left join lastknownpi
              ON P.protocol_id = lastknownpi.protocol_id
--where p.protocol_no = '2002348365'