insert into ActivePI(email,UA_NETID,LAST_NAME,FIRST_NAME,STAFF_NAME,college,dept)
select distinct 
p.pi_netid email,
substring(p.pi_netid,0,CHARINDEX('@',p.pi_netid)) UA_NETID ,
LEFT(pi_name,CHARINDEX(',',pi_name)-1) as LAST_NAME,
SUBSTRING(pi_name,CHARINDEX(' ',pi_name),LEN(PI_NAME)) as FIRST_NAME,
pi_name STAFF_NAME,
-1 as college,
-1 as dept from protocols p
left outer join (select ap.UA_NETID netid from ActivePI ap) app
on substring(p.pi_netid,0,CHARINDEX('@',p.pi_netid)) = app.netid
where netid is null