use OnCoreDW
go
-------------------------------------------------------------------
-----------------Dimension PI--------------------------------------
create table [dw].[DimPI](
[surrKey] [int] identity(1,1) not null,
[LAST_NAME] [nvarchar](50) NOT NULL,
	[FIRST_NAME] [nvarchar](50) NOT NULL,
	[STAFF_NAME] [nvarchar](50) NOT NULL,
	[EMAIL] [nvarchar](50) NOT NULL,
	[UA_NETID] [nvarchar](50) NOT NULL,
	[EID] [int] NULL,
	[DEPT_ID] [smallint] NULL,
	[College] [nvarchar](50) NOT NULL,
	[DEPT] [nvarchar](50) NOT NULL,
	constraint [PK_DimPI_surrKey] primary key clustered ([surrKey] asc)
)ON [PRIMARY]
GO
-----------------Dimension PI--------------------------------------
-------------------------------------------------------------------


-------------------------------------------------------------------
-----------------FACT ENROLLMENTS----------------------------------
  create table [dw].[FactEnrollments](
  [surrKey] [int] identity(1,1) not null,
  Protocol_Key [int] not null,
  On_StudyDate_Key [int] not null,
  NumberOfEnrollments[int] null,
  constraint [PK_FactEnrollments_surrKey] primary key clustered ([surrKey] asc)
  )ON [PRIMARY]
GO
  CREATE NONCLUSTERED INDEX [UQ_FactEnrollments_Protocol_Key] ON [dw].[FactEnrollments] ([PROTOCOl_Key])
  CREATE NONCLUSTERED INDEX [UQ_FactEnrollments_On_StudyDate_Key] ON [dw].[FactEnrollments] ([On_StudyDate_Key])

-----------------FACT ENROLLMENTS----------------------------------
-------------------------------------------------------------------


----------------------------------------------------------------
-----------------FACT PROTOCOL----------------------------------


CREATE TABLE dw.[FactProtocols](
[surrKey] [int] identity(1,1) not null,
	[protocol_id] [int] NULL,
	[protocol_no] [nvarchar](35) NULL,
	[Title] [nvarchar](4000) NULL,
	[PI_Key] INT NULL,
	[ManagementGroup_Key] int NULL,
	[Protocol_Institutions] [nvarchar](100) NULL,
	[Department_Name] [nvarchar](50) NULL,
	[Library] [nvarchar](50) NULL,
	[Data_Monitoring] [nvarchar](200) NULL,
	[LowerTargetAccrual] [int] NULL,
	[UpperTargetAccrual] [int] NULL,
	[Current_Status] [nvarchar](30) NULL,
	[Created_Date_Key] int not NULL,
	[Initial_Open_Date] [date] NULL,
	[Closed_Date] [date] NULL,
	[Current_Status_Date] [date] NULL,
	[Study_Closure_Date] [date] NULL,
	constraint [PK_FactProtocols_surrKey] primary key clustered ([surrKey] asc)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX UQ_FACTPROTOCOLS_PI_Key ON [dw].[FACTPROTOCOLS] (PI_Key)
CREATE NONCLUSTERED INDEX UQ_FACTPROTOCOLS_MGP_Key ON [DW].[FACTPROTOCOLS] (MANAGEMENTGROUP_KEY)
CREATE NONCLUSTERED INDEX UQ_FACTPROTOCOLS_Created_Date_Key on [DW].[FACTPROTOCOLS] (CREATED_DATE_KEY)

-----------------FACT PROTOCOL----------------------------------
----------------------------------------------------------------

-----------------------------------------------------------------------------
-----------------DIMENSION MANAGEMENT GROUP----------------------------------
CREATE TABLE [dw].[DimManagementGroup](
[surrKey] [int] identity(1,1) not null,
	[ONC_MANAGEMENT_GROUP_ID] [numeric](10, 0) NULL,
	[NAME] [nvarchar](255) NULL,
	[CODE] [nvarchar](12) NULL,
	constraint [PK_DimManagementGroup_surrKey] primary key clustered ([surrKey] asc)
) ON [PRIMARY]
GO
-----------------DIMENSION MANAGEMENT GROUP----------------------------------
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-----------------RELATIONSHIP CREATION---------------------------------------

--ALTER TABLE [dw].[]
--ADD CONSTRAINT FK_ FOREIGN KEY () REFERENCES [DW].[] ([]);

ALTER TABLE [dw].[FactEnrollments]
ADD CONSTRAINT FK_Enrollments_DimDate FOREIGN KEY (On_StudyDate_Key) REFERENCES [dw].[DimDate] ([DateKey]);
ALTER TABLE [dw].[FactEnrollments]
ADD CONSTRAINT FK_Enrollments_Protocols FOREIGN KEY (Protocol_Key) REFERENCES [dw].FACTPROTOCOLS ([surrKey]);


ALTER TABLE [dw].[FactProtocols]
ADD CONSTRAINT FK_FactProtocols_DimManagementGroup FOREIGN KEY (ManagementGroup_Key) REFERENCES [DW].[DimManagementGroup] ([surrKey]);
ALTER TABLE [dw].[FactProtocols]
ADD CONSTRAINT FK_FactProtocols_DimPI FOREIGN KEY (PI_Key) REFERENCES [DW].[DimPI] ([surrKey]);
ALTER TABLE [dw].[FactProtocols]
ADD CONSTRAINT FK_FactProtocols_DimDate FOREIGN KEY (Created_Date_Key) REFERENCES [DW].[DimDate] ([DateKey]);

-----------------RELATIONSHIP CREATION---------------------------------------
-----------------------------------------------------------------------------


---------------------------------------------------------------------------------
-----------------Initialization--------------------------------------------------


  delete from [dw].[dimaudit] where auditkey <> -1
  DBCC CHECKIDENT ('[dw].[dimaudit]', RESEED, 0);

    delete from [dw].[DimManagementGroup] where surrkey <> -1
  DBCC CHECKIDENT ('[dw].[DimManagementGroup]', RESEED, 0);

    delete from [dw].[DimPI] where surrkey <> -1
  DBCC CHECKIDENT ('[dw].[DimPI]', RESEED, 0);

  truncate table [oncoredw].dw.factprotocols

  delete from [dw].[FactProtocols] where surrkey <> -1
  DBCC CHECKIDENT ('[dw].[FactProtocols]', RESEED, 0);

  delete from [dw].[FactEnrollments] where surrkey <> -1
  DBCC CHECKIDENT ('[dw].[FactEnrollments]', RESEED, 0);

    delete from [dw].[DimPI] where surrkey <> -1
  DBCC CHECKIDENT ('[dw].[DimPI]', RESEED, 0);

  
SET IDENTITY_INSERT [dw].[DimDate] ON

USE [OnCoreDW]
GO



SET IDENTITY_INSERT [dw].[DimDate] OFF

use OnCoreStaging
go


ALTER TABLE dbo.Protocols
ADD CONSTRAINT DF_ProtocolsCreated_Date
DEFAULT ('1900-01-01') FOR [Created_Date];
ALTER TABLE dbo.Protocols
ADD CONSTRAINT DF_Protocols_InitialOpenDate
DEFAULT ('1900-01-01') FOR Initial_Open_Date;
ALTER TABLE dbo.Protocols
ADD CONSTRAINT DF_Protocols_Closed_Date
DEFAULT ('1900-01-01') FOR [Closed_Date];
ALTER TABLE dbo.Protocols
ADD CONSTRAINT DF_Protocols_Current_Status_Date
DEFAULT ('1900-01-01') FOR [Current_Status_Date];
ALTER TABLE dbo.Protocols
ADD CONSTRAINT DF_Protocols_Study_Closure_Date
DEFAULT ('1900-01-01') FOR [Study_Closure_Date];

ALTER TABLE dbo.Protocols
ADD CONSTRAINT DF_Protocols_PI_Email
DEFAULT 'NA' FOR PI_Email;

ALTER TABLE dbo.Protocols
ADD CONSTRAINT DF_Protocols_ManagementGroup
DEFAULT 'NA' FOR ManagementGroup;


USE [OnCoreStaging]
GO

INSERT INTO [dbo].[ManagementGroup]
           ([ONC_MANAGEMENT_GROUP_ID]
           ,[NAME]
           ,[CODE]
           ,[ACTIVE_FLAG]
           ,[CREATED_USER]
           ,[CREATED_DATE]
           ,[MODIFIED_USER]
           ,[MODIFIED_DATE])
     VALUES
           (-1
           ,'NA'
           ,'NA'
           ,-1
           ,-1
           ,'1900-01-01'
           ,'1900-01-01'
           ,'1900-01-01')
GO

-- 302	COMP-DOM-Clinical Data Analytics and Decision Support	0669_CDADS	1	2928	2020-01-21	2928	2021-04-23

-----------------Initialization-------------------------------------------------
---------------------------------------------------------------------------------



-----------------------------------------------------------------------------
-----------------REGION---------------------------------------
-----------------REGION---------------------------------------
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-----------------PLAYGROUND--------------------------------------------------

--select distinct managementgroup from ManagementGroup mg , protocols p where mg.NAME = p.ManagementGroup
--select distinct p.managementgroup as P, mg.NAME as MG from ManagementGroup mg full outer join protocols p on p.ManagementGroup = mg.NAME
--select DISTINCT p.pi_email EmailfromProtocol, api.email EmailFromActivePI, api.UA_NETID FROM PROTOCOLS P LEFT OUTER JOIN  ACTIVEPI API ON P.PI_Email = API.EMAIL
--WHERE api.email IS NULL
--SELECT DISTINCT api.email EmailFromActivePI, api.UA_NETID FROM ACTIVEPI API WHERE UA_NETID IS NULL
--select * from Enrollments e
--where e.On_StudyDate is null or e.Protocol_No is null
----group by e.On_StudyDate

--SELECT * FROM PROTOCOLS P
 
--alter table dw.factprotocols drop column [Initial_Open_Date]
--alter table dw.factprotocols drop column [Closed_Date]
--alter table dw.factprotocols drop column [Current_Status_Date]
--alter table dw.factprotocols drop column [Study_Closure_Date]
--alter table dw.factprotocols add [Initial_Open_Date_key] int
--alter table dw.factprotocols add [Closed_Date_key] int
--alter table dw.factprotocols add [Current_Status_Date_key] int
--alter table dw.factprotocols add [Study_Closure_Date_key] int

--drop table dw.factenrollments


--  CREATE UNIQUE NONCLUSTERED INDEX idx_uniq_date ON [dw].[DimDate]([Date])

--  ALTER TABLE [dw].[FactEnrollments]
--ADD CONSTRAINT FK_Enrollments_DimDate FOREIGN KEY (ChildColumn) REFERENCES [dw].[DimDate]([Date]);

alter table [dw].[DimManagementGroup]
add AuditKey int;
alter table [dw].[DimPI]
add AuditKey int;
alter table [dw].[FactEnrollments]
add AuditKey int;
alter table [dw].[FactProtocols]
add AuditKey int;

-----------------PLAYGROUND--------------------------------------------------
-----------------------------------------------------------------------------
