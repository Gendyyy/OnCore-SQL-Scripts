-- SQL Server 2019: Major version 15
-- SQL Server 2017: Major version 14
-- SQL Server 2016: Major version 13
-- SQL Server 2014: Major version 12
-- SQL Server 2012: Major version 11
-- SQL Server 2008 R2: Major version 10.5
-- SQL Server 2008: Major version 10
-- SQL Server 2005: Major version 9

-- Truncate and Reset the identity Counter --
  delete from oncoredw.[dw].[DimAudit]
  where AuditKey != -1
  DBCC CHECKIDENT ('oncoredw.[dw].[DimAudit]', RESEED, 1);


-- Get which edition and the running bitness (i.e. Standard Edition (64-bit)) --
SELECT SERVERPROPERTY('Edition') AS 'SQL Server Edition';

-- Get Product Version, Product Level, Edition
SELECT 
    SERVERPROPERTY('ProductVersion') AS 'Product Version',
    SERVERPROPERTY('ProductLevel') AS 'Product Level',
    SERVERPROPERTY('Edition') AS 'Edition'


