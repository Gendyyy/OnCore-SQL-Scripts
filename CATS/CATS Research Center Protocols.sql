select p.protocol_no,
       p.Title,
       p.pi_name,
       p.Department_Name,
       Race,
       Ethnicity,
       sum(e.NumberOfEnrollments) NumberOfEnrollments
from Protocols p
         left join Enrollments e on p.protocol_no = e.Protocol_No
where p.StudySites = 'CaTS Research Center'
and p.Created_Date between '2021-01-01' and '2023-12-31'
group by p.protocol_no,
         p.Title,
         p.pi_name,
         p.Department_Name,
         Race,
         Ethnicity
order by protocol_no, Race, Ethnicity