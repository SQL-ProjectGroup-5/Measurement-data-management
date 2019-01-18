-- The aim of the stored procedure (SP) is to 
-- enable users the possibility to get the minimum (min) 
-- and maximum (max) measurement value over a period of time. 
-- The start and end date can be specified via parameters. 
-- Depending on the parameters, the SP can return the total min/max 
-- value over the provided period, or min/max values per day. 

GO
CREATE PROCEDURE dbo.sp_analyze_values
    @subscriber_id INT,
    @sensor_id INT,
    @from_date char(40),
    @to_date char(40),
    @daily_evaluation BIT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @countDays INT;
    DECLARE @staticCountDays INT;


    IF (SELECT COUNT(*) 
        FROM dbo.sensor  
        WHERE @sensor_id = sensor_ID) = 0 --check if sensor exists!
    BEGIN
        SELECT 50001 AS ERRORNUMBER, CONCAT('Sensor with ID ',@sensor_id,' not availabe!') AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50001,CONCAT('Sensor with ID ',@sensor_id,' not availabe!')); 
        RETURN
    END
    ELSE IF (SELECT COUNT(*) 
            FROM dbo.user_permission  
            WHERE @subscriber_id = subscriber_ID AND @sensor_id=sensor_ID) = 0 --check if subscriber has permition to subscribe a sensor
            BEGIN
                SELECT 50002 AS ERRORNUMBER, CONCAT('Subscriber has no permission on: ',@sensor_id) AS ERRORMESSAGE; 
                INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50002,CONCAT('Subscriber has no permission on: ',@sensor_id)); 
                RETURN
            END
    ELSE IF (SELECT COUNT(*) 
            FROM dbo.user_permission 
            WHERE @subscriber_id = subscriber_ID AND (GETDATE() NOT BETWEEN valid_from AND valid_to) AND sensor_ID=@sensor_id)>0--CHECK if permition is still valid
    BEGIN
        SELECT 50003 AS ERRORNUMBER,CONCAT('Subscriber permission expired for sensor: ', @sensor_id) AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50003,CONCAT('Subscriber permission expired for sensor: ', @sensor_id)); 
        RETURN
    END
    BEGIN TRY
        --check if data format and input is incorrect:
        IF @from_date>@to_date
        BEGIN
            SELECT 50004 AS ERRORNUMBER, 'from-date greater than to-date' AS ERRORMESSAGE; 
            INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50004,'from-date greater than to-Datum'); 

            RETURN
        END
        IF TRY_CONVERT(DATETIME2,@from_date) IS NULL
        BEGIN
            SELECT 50005 AS ERRORNUMBER, 'from-date format wrong' AS ERRORMESSAGE;
            INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50005,'from-date format wrong'); 

            RETURN
        END
        ELSE IF TRY_CONVERT(DATETIME2,@to_date) IS NULL
            BEGIN
            SELECT 50006 AS ERRORNUMBER, 'to-date format wrong' AS ERRORMESSAGE;
            INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50006, 'to-date format wrong'); 
            RETURN
        END

        IF ( SELECT COUNT(*) --check if values in period of time exist
            FROM dbo.measurement
            WHERE ((measure_time BETWEEN @from_date AND @to_date) AND sensor_ID = @sensor_id AND @from_date!=@to_date))=0 --also check if von_dat = bis_dat
            BEGIN
                SELECT 50007 AS ERRORNUMBER,CONCAT('No measurements available for sensor: ', @sensor_id,' between ',@from_date, ' and ',@to_date) AS ERRORMESSAGE; 
                INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50007, CONCAT('No measurements available for sensor: ', @sensor_id)); 
                RETURN
            END 

        ELSE
        BEGIN
            IF @daily_evaluation = 1
            BEGIN
                SET @countDays = DATEDIFF(Day, @from_date, @to_date)
                SET @staticCountDays = @countDays

                IF @countDays > 365
                BEGIN
                    SELECT 50008 AS ERRORNUMBER, 'Date difference between from-date and to-date less than 365 days' AS ERRORMESSAGE; 
                    INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_rekord_werte',50008, 'Date difference > 365'); 
                    RETURN
                END

                --get days out of range: then transform starting date starts at: 00:00 and ends at 23:59
                --not using split String functions, because delimeter might change!!
                --built in convert functions are more agile.

                SET @from_date = CONVERT(DATETIME2,CONVERT(DATE,@from_date))AT TIME ZONE 'Central European Standard Time'
                
                SET @to_date = DATEADD(MINUTE,59,DATEADD(HOUR,23,(CONVERT(DATETIME2,@from_date))AT TIME ZONE 'Central European Standard Time')) --time set to 23:59
                
                CREATE TABLE #tempValues --creates a temporary table  
                (  
                    nr  INT IDENTITY(1,1),
                    typ char(10),  
                    messwert float,
                    datum datetime  
                    CONSTRAINT PK_nr PRIMARY KEY (nr)
                )
    
                WHILE @countDays >0
                BEGIN
                    
                 
                    INSERT INTO #tempValues (typ,messwert,datum)
                    SELECT TOP 1 'min' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                    value_corrected = (SELECT MIN(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date ))
                    AND (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date )
                    UNION
                    SELECT TOP 1 'max' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                    value_corrected = (SELECT MAX(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date)) 
                    AND (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date )

                    --add 1 day 
                    SET @from_date = DATEADD(DAY,1,(CONVERT(DATETIME2,@from_date))AT TIME ZONE 'Central European Standard Time')
                    SET @to_date = DATEADD(DAY,1,(CONVERT(DATETIME2,@to_date))AT TIME ZONE 'Central European Standard Time')
                    SET @countDays -= 1;
                END
                
                SELECT * FROM #tempValues

            END
            ELSE --return min, max value over a period of time
            BEGIN
                
                SELECT TOP 1 'min' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                value_corrected = (SELECT MIN(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date ))
                AND (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date )
                UNION
                SELECT TOP 1 'max' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                value_corrected = (SELECT MAX(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date)) 
                AND (sensor_ID = @sensor_id AND measure_time BETWEEN @from_date AND @to_date )
            END
           
        END
       
    END TRY
    BEGIN CATCH
         SELECT ERROR_NUMBER() AS Fehlernummer, ERROR_MESSAGE() AS Fehlermeldung; -- default error
    END CATCH
    
END
