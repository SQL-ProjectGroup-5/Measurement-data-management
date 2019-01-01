--Selects zum Testen
SELECT *
FROM dbo.[location];
SELECT *
FROM dbo.station;
SELECT *
FROM dbo.[type];
SELECT *
FROM dbo.channel;
SELECT *
FROM dbo.sensor;

SELECT *
FROM dbo.measurement
ORDER BY dbo.measurement.measure_time;

SELECT *
FROM dbo.sensor_group;
SELECT *
FROM dbo.subscriber;
SELECT *
FROM dbo.subscription
SELECT *
FROM dbo.user_permission
SET DATEFORMAT ymd; 

--Error number:
--50001: 'Sensor mit ID ',@sensor_id,' nicht vorhanden!'
--50002: 'Subscriber hat keine Zugriffsrechte auf Sensor: ',@sensor_id
--50003: 'Subscriber Zugriffsrecht abgelaufen fuer Sensor: ', @sensor_id
--50004: 'von-Datum groesser als ist-Datum'
--50005: 'von Datum falsch'
--50006: 'bis Datum falsch'


--day month year
--Ideen für Error-Handling
-- Subscriber der nicht die Berechtigung eines Sensors beitzt, bzw ihn nicht subscript bekommt Fehler
-- Datum wurde im falschen Format übergeben: yyyy-mm-dd
-- Permission abgelaufen, aus Tabelle User-permission auslesen
-- Sensor muss gültig sein, sonst Fehler

--Ergebnisrückgabe mittels SELECT --> einfach für Frontend
-- datum als String übergeben, da sonst ein falsches datum nicht überprueft werden kann, weil datumsuepruefung auf selben Level wie Try und Catch ist!
--Date input as string, because if the input is datatype 'date' the error level in case of a wrong date is not in range between 10-19 thus cannot be handled in trycatch block!
GO
ALTER PROCEDURE dbo.sp_rekord_werte
    @subscriber_id INT,
    @sensor_id INT,
    @von_datum char(40),
    @bis_datum char(40),
    @separate_messwerte BIT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @countDays INT;
    DECLARE @staticCountDays INT;

    --new 29.12
    DECLARE @buffer_date DATE;
    DECLARE @buffer_datetime2 DATETIME2;

    IF (SELECT COUNT(*) 
        FROM dbo.sensor  
        WHERE @sensor_id = sensor_ID) = 0 --check if sensor exists!
    BEGIN
        SELECT 50001 AS Fehlernummer, CONCAT('Sensor mit ID ',@sensor_id,' nicht vorhanden!') AS Fehlermeldung; 
        RETURN
    END
    ELSE IF (SELECT COUNT(*) 
            FROM dbo.user_permission  
            WHERE @subscriber_id = subscriber_ID AND @sensor_id=sensor_ID) = 0 --check if subscriber has permition to subscribe a sensor
            BEGIN
                SELECT 50002 AS Fehlernummer, CONCAT('Subscriber hat keine Zugriffsrechte auf Sensor: ',@sensor_id) AS Fehlermeldung; 
                RETURN
            END
    ELSE IF (SELECT COUNT(*) 
            FROM dbo.user_permission 
            WHERE @subscriber_id = subscriber_ID AND (GETDATE() BETWEEN valid_from AND valid_to OR valid_to IS NULL))=0--CHECK if permition is still valid
    BEGIN
        SELECT 50003 AS Fehlernummer,CONCAT('Subscriber Zugriffsrecht abgelaufen fuer Sensor: ', @sensor_id) AS Fehlermeldung; 
        RETURN
    END
    BEGIN TRY
        --check if data format and input is incorrect:
        IF @von_datum>@bis_datum
        BEGIN
            SELECT 50004 AS Fehlernummer, 'von-Datum groesser als ist-Datum' AS Fehlermeldung; 
            RETURN
        END
        IF TRY_CONVERT(DATETIME2,@von_datum) IS NULL
        BEGIN
            SELECT 50005 AS Fehlernummer, 'von Datum falsch' AS Fehlermeldung; 
            RETURN
        END
        ELSE IF TRY_CONVERT(DATETIME2,@bis_datum) IS NULL
            BEGIN
            SELECT 50006 AS Fehlernummer, 'bis Datum falsch' AS Fehlermeldung; 
        RETURN
        END

        IF ( SELECT COUNT(*) --check if values in period of time exist
            FROM dbo.measurement
            WHERE ((measure_time BETWEEN @von_datum AND @bis_datum) AND sensor_ID = @sensor_id AND @von_datum!=@bis_datum))=0 --also check if von_dat = bis_dat
            BEGIN
                SELECT 50007 AS Fehlernummer,CONCAT('Keine Messwerte vorhanden fuer Sensor: ', @sensor_id,' zwischen ',@von_datum, ' und ',@bis_datum) AS Fehlermeldung; 
                RETURN
            END 

        ELSE
        BEGIN
            IF @separate_messwerte = 1
            BEGIN
                SET @countDays = DATEDIFF(Day, @von_datum, @bis_datum)
                SET @staticCountDays = @countDays

                --get days out of range: then transform starting date starts at: 00:00 and ends at 23:59
                --SET @start_day = CONVERT(Date@von_datum)
                
                SET @buffer_datetime2 = CONVERT(DATETIME2,CONVERT(DATE,@von_datum))AT TIME ZONE 'Central European Standard Time' --time set 00:00
                --PRINT(@buffer_datetime2)
                SET @von_datum = @buffer_datetime2 AT TIME ZONE 'Central European Standard Time'
                
                SET @bis_datum = DATEADD(MINUTE,59,DATEADD(HOUR,23,(CONVERT(DATETIME2,@von_datum))AT TIME ZONE 'Central European Standard Time')) --time set to 23:59
                --PRINT(@buffer_datetime2)
                --not using split String functions, because delimeter might change!!
                --built in convert functions are more agile.

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
                    --INSERT INTO #tempValues(typ,messwert,datum)
                    --VALUES('min',21.22,'2018-11-11');

                    --new version: select all measurements in time range and buffer in table
                 
                    INSERT INTO #tempValues (typ,messwert,datum)
                    SELECT TOP 1 'min' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                    value_corrected = (SELECT MIN(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum ))
                    AND (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum )
                    UNION
                    SELECT TOP 1 'max' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                    value_corrected = (SELECT MAX(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum)) 
                    AND (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum )

                    PRINT(@von_datum)
                    PRINT(@bis_datum)

                    --add 1 day 
                    SET @von_datum = DATEADD(DAY,1,(CONVERT(DATETIME2,@von_datum))AT TIME ZONE 'Central European Standard Time')
                    SET @bis_datum = DATEADD(DAY,1,(CONVERT(DATETIME2,@bis_datum))AT TIME ZONE 'Central European Standard Time')

                   
                    --PRINT @von_datum
                    --PRINT DATEADD(DAY,@staticCountDays-@countDays, CONVERT(DATETIME2,@von_datum))
                    SET @countDays -= 1;
                END
                
                SELECT * FROM #tempValues

            END
            ELSE --return min, max value over a period of time
            BEGIN
                
                
                SELECT TOP 1 'min' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                value_corrected = (SELECT MIN(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum ))
                AND (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum )
                UNION
                SELECT TOP 1 'max' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE 
                value_corrected = (SELECT MAX(value_corrected) FROM dbo.measurement WHERE (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum)) 
                AND (sensor_ID = @sensor_id AND measure_time BETWEEN @von_datum AND @bis_datum )
            END
           
        END
       
    END TRY
    BEGIN CATCH
         SELECT ERROR_NUMBER() AS Fehlernummer, ERROR_MESSAGE() AS Fehlermeldung; -- default error
    END CATCH
    
END



EXEC dbo.sp_rekord_werte @subscriber_id = 1, @sensor_id = 4 ,@von_datum = '2018-11-02 00:00:00 +01:00',@bis_datum = '2018-11-20 23:59:00 +01:00',@separate_messwerte= 1

SELECT 'min' AS TYPE, min(value_corrected) FROM dbo.measurement WHERE (measure_time BETWEEN '2018-11-04 00:00:00 +01:00' AND '2018-11-04 23:59:00 +01:00')


SELECT * FROM dbo.measurement WHERE sensor_ID=4 AND measure_time BETWEEN '2018-11-20 00:00:00 +01:00'AND '2019-11-20 23:59:00 +01:00'

SELECT TRY_CONVERT([date], '12/32/2010') AS Result;  

SELECT COUNT(*) FROM dbo.user_permission sub WHERE 1 = sub.subscriber_ID

SELECT GETDATE() as sss

SELECT COUNT(*) FROM dbo.user_permission per WHERE 1 = per.subscriber_ID AND (GETDATE() BETWEEN per.valid_from AND per.valid_to OR per.valid_to IS NULL)-- OR (per.valid_from >= GETDATE() AND per.valid_to IS NULL)

SELECT COUNT(*) FROM dbo.user_permission per WHERE 1 = per.subscriber_ID AND per.valid_to IS NULL


SELECT COUNT(*)
            FROM dbo.sensor sen
            INNER  JOIN dbo.measurement meas ON meas.sensor_ID = sen.sensor_ID
            WHERE (measure_time BETWEEN '2018-11-01' AND '2018-12-02') AND sen.sensor_ID = 4

SELECT * FROM dbo.measurement WHERE(sensor_ID = 4 AND measure_time BETWEEN '2018-11-17 00:00:00 +01:00' AND '2018-11-17 23:59:59 +01:00') ORDER BY measure_time

SELECT * FROM dbo.measurement WHERE(sensor_ID = 4 AND  measure_time BETWEEN '2018-11-13 ' AND '2018-11-13 ') ORDER BY measure_time

SELECT * FROM dbo.measurement WHERE(sensor_ID = 4)  ORDER BY value_corrected

 SELECT MAX(value_corrected) AS max, MIN(value_corrected) AS min
                FROM dbo.measurement
                WHERE ((('2018-11-01 00:00:00 +01:00' = '2018-11-01 00:00:00 +01:00' AND DATEDIFF(Day,'2018-11-17 00:00:00 +01:00',measure_time) =1)) AND sensor_ID = 4)


DECLARE @datetime2 datetime2 = '2007-01-01 13:10:10.1111111';  
SELECT '1 millisecond', DATEADD(MINUTE,1,@datetime2),DATEADD(MINUTE,1,@datetime2);


SELECT TOP 1 'min' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE value_corrected = (SELECT MIN(value_corrected) FROM dbo.measurement WHERE (measure_time BETWEEN '2018-11-17 00:00:00 +01:00' AND '2018-11-17 23:59:59 +01:00' AND sensor_ID = 4))
UNION
SELECT TOP 1 'max' AS typ, value_corrected, measure_time FROM dbo.measurement WHERE value_corrected = (SELECT MAX(value_corrected) FROM dbo.measurement WHERE (measure_time BETWEEN '2018-11-17 00:00:00 +01:00' AND '2018-11-17 23:59:59 +01:00' AND sensor_ID = 4)) 
