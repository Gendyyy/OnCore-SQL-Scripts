select protocol_no,
max(case when  CHARINDEX('new',lower(status)) != 0 then status_date end) as New_Date,
max(case when  CHARINDEX('closed',lower(status)) != 0 then status_date end) as Completed_Date
  from protocolstatushistory
group by protocol_no