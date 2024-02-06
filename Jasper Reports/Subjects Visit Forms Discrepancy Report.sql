select
                   spfd.protocol_no,
                   case (select count(*) from sv_user_pcl_permission upp where upp.contact_id = $P{userContactId} and upp.protocol_id = spfd.protocol_id and upp.function_name = 'SUBJECT-IDENTIFICATION')
                     when 1 then spfd.subject_mrn
                     else '*********'
                   end subject_mrn,
                   spfd.sequence_number,
                   form_no,
                   procedure,
                   visit,
                   discrepancy,
                   response,
                   disc_created_date disc_display_date,
                   to_date(disc_created_date, 'MM/DD/YYYY') disc_created_date,
                   disc_created_user,
                   to_date(resp_created_date, 'MM/DD/YYYY') resp_created_date,
                   resp_created_date resp_display_date,
                   resp_created_user,
                   disc_status,
                   resolved_time,
                   study_site

                 from
                   FROM_DISCREPANCIES spfd
                   LEFT JOIN uacc_oncore_prod.rv_subject_visit_procedure VP
ON spfd.SD_PCS_TRACKING_EVALUATION_ID = VP.SD_PCS_TRACKING_EVALUATION_ID
                 where
                   spfd.protocol_no like '%' || $P{ProtocolNo} || '%'
                   and form_no like '%' || $P{FormNo} || '%'
                   and disc_status in ('Open', decode($P{ActiveFlag}, NULL, 'Closed', NULL))
                   and (to_date(disc_created_date, 'MM/DD/YYYY') >= NVL($P{CreatedFromDate}, to_date(disc_created_date, 'MM/DD/YYYY')))
                   and (to_date(disc_created_date, 'MM/DD/YYYY') <= NVL($P{CreatedToDate}, to_date(disc_created_date, 'MM/DD/YYYY')))
                   and ($P{StudySite} is null or $P{StudySite} = study_site)
                   and protocol_id in
                   (
                     select
                       upp.protocol_id
                     from
                       sv_user_pcl_permission upp
                     where
                       upp.contact_id = $P{userContactId}
                       and upp.function_name = 'CRA-CONSOLE'
                   )
                   and protocol_subject_id in
                   (
                     select
                       pcsa.protocol_subject_id
                     from
                       sv_user_pcs_access pcsa
                     where
                       pcsa.contact_id = $P{userContactId}
                   )
                 order by
                   spfd.protocol_no,
                   spfd.form_no