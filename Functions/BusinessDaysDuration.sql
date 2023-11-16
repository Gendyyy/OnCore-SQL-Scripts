CREATE FUNCTION dbo.BusinessDaysDuration(@StartDate DATE, @EndDate DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Duration INT = 0;
    DECLARE @CurrentDate DATE = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        -- Check if the current day is not a Saturday (6) or Sunday (0)
        IF DATEPART(WEEKDAY, @CurrentDate) NOT IN (1, 7)
        BEGIN
            SET @Duration = @Duration + 1;
        END

        -- Move to the next day
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END

    RETURN @Duration;
END;