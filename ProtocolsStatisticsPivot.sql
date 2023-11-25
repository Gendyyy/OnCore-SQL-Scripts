DECLARE @Dates NVARCHAR(MAX) =
'[' + CAST(YEAR(GETDATE())-5 AS NVARCHAR(4)) + ']' + ',' +
'[' + CAST(YEAR(GETDATE())-4 AS NVARCHAR(4)) + ']' + ',' +
 '[' + CAST(YEAR(GETDATE())-3 AS NVARCHAR(4)) + ']' + ',' +
                               '[' + CAST(YEAR(GETDATE())-1 AS NVARCHAR(4)) + ']' + ',' +
                               '[' + CAST(YEAR(GETDATE()) AS NVARCHAR(4)) + ']';
Declare @Sql NVARCHAR(max);

set @Sql = N'
    SELECT *
    FROM (
        SELECT p.protocol_no,
               d.FY,
               d.FYQ
        FROM Protocols p
        INNER JOIN OnCoreDW.dw.dimdate d ON d.[Date] = p.Created_Date
        WHERE d.FY != 0
    ) AS source
    PIVOT (
        COUNT(source.protocol_no) FOR source.FY IN (' + @Dates + ')
    ) AS asd
    ORDER BY fyq;
';

EXEC sp_executesql @Sql;