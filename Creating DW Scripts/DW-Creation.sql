-- drop table [dw].[dimaudit]
create table [dw].[DimAudit](
    [Auditkey] [int] IDENTITY(1,1) not null,
    [ParentAuditKey] [int] not null,
    [TableName] [varchar](50) not null,
    [PkgName] [varchar](50) not null,
    [PkgGUID] [uniqueidentifier] null,
    [ExecStartDate] [datetime] not null,
    [ExecStopDate] [datetime] null,
    [ExecutionInstanceGUID] [uniqueidentifier] null,
    [ExtractRowCount] [int] null,
    [InsertRowCount] [int] null,
    [UpdateRowCount] [int] null,
    [ErrorRowCount] [int] null,
    [TableInitialRowCount] [int] null,
    [TableFinalRowCount] [int] null,
    [TableMaxDateTime] [datetime] null,
    [SuccessfulProcessing] [char](1) not null,
    CONSTRAINT [PK_dw.DimAudit] Primary key clustered(
        [AuditKey] asc
    )
)
SET IDENTITY_INSERT [dw].[DimAudit] on
INSERT [dw].[DimAudit]
	([AuditKey], [ParentAuditKey], [TableName], [PkgName], [PkgGUID], [ExecStartDate], [ExecStopDate], [ExecutionInstanceGUID], [ExtractRowCount], [InsertRowCount], [UpdateRowCount], [ErrorRowCount], [TableInitialRowCount], [TableFinalRowCount], [TableMaxDateTime], [SuccessfulProcessing])
VALUES
	(-1, -1, N'Not Applicable', N'Initial Load', NULL, getdate(), getdate(), NULL, 0, 0, 0, 0, 0, 0, getdate(), N' ')
SET IDENTITY_INSERT [dw].[DimAudit] OFF

-- ===================================================
-- Creating DimDate with respect to fiscal year of UoA
-- following the below pattern
-- '07/01/2021','09/30/2021' FY2022 Q1
-- '10/01/2021','12/31/2021' FY2022 Q2
-- '01/01/2022','03/31/2022' FY2022 Q3
-- '04/01/2022','06/30/2022',  FY2022 Q4
-- ===================================================


CREATE TABLE [dw].[DimDate] (
    DateKey INT PRIMARY KEY,
    Date DATE,
    Year INT,
    Q VARCHAR(2),
    FY INT,
    FYQ VARCHAR(2),
    Month INT,
    Week INT,
    Day INT
);

-- Populate the table
DECLARE @StartDate DATE = '1970-01-01';
DECLARE @EndDate DATE = '2040-12-31';
DECLARE @CurrDate DATE = @StartDate;

WHILE @CurrDate <= @EndDate
BEGIN
    -- Determine the fiscal year and fiscal quarter based on your pattern
    DECLARE @FiscalYear INT = YEAR(@CurrDate) + 
        CASE 
            WHEN MONTH(@CurrDate) BETWEEN 7 AND 12 THEN 1 
            ELSE 0 
        END;

    DECLARE @FiscalQuarter VARCHAR(2);
    IF MONTH(@CurrDate) BETWEEN 7 AND 9
        SET @FiscalQuarter = 'Q1';
    ELSE IF MONTH(@CurrDate) BETWEEN 10 AND 12
        SET @FiscalQuarter = 'Q2';
    ELSE IF MONTH(@CurrDate) BETWEEN 1 AND 3
        SET @FiscalQuarter = 'Q3';
    ELSE
        SET @FiscalQuarter = 'Q4';

    -- Determine the calendar quarter
    DECLARE @CalendarQuarter VARCHAR(2) = 'Q' + CAST(CEILING(MONTH(@CurrDate) / 3.0) AS VARCHAR);

    INSERT INTO [dw].[DimDate] (DateKey, Date, Year, Q, FY, FYQ, Month, Week, Day)
    VALUES (
        CONVERT(INT, REPLACE(CONVERT(VARCHAR, @CurrDate, 112), '-', '')), -- Date in YYYYMMDD format
        @CurrDate,
        YEAR(@CurrDate),
        @CalendarQuarter,
        @FiscalYear,
        @FiscalQuarter,
        MONTH(@CurrDate),
        DATEPART(WEEK, @CurrDate),
        DAY(@CurrDate)
    );

    -- Increment the date
    SET @CurrDate = DATEADD(DAY, 1, @CurrDate);
END;


