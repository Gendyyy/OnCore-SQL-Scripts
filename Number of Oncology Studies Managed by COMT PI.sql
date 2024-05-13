select ps.Phase, count(distinct p.protocol_no) [Number of Oncology Studies Managed by COMT PI] from Protocols p
inner join OnCoreDW.dw.DimPI dp on p.pi_name = dp.STAFF_NAME
                                     inner join dbo.ProtocolStatus PS on p.Current_Status = PS.current_status
where
    p.Library = 'Oncology'
and dp.College = 'College of Medicine - Tucson'
group by ps.Phase