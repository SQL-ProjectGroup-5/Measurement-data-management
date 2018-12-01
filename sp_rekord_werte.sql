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

--Ideen für Error-Handling
-- Subscriber der nicht die Berechtigung eines Sensors beitzt, bzw ihn nicht subscript bekommt Fehler
-- Datum wurde im falschen Format übergeben: yyyy-mm-dd
-- Permission abgelaufen, aus Tabelle User-permission auslesen
-- Sensor muss gültig sein, sonst Fehler

--Ergebnisrückgabe mittels SELECT --> einfach für Frontend
<<<<<<< HEAD

--Date input as string, because if the input is datatype 'date' the error level in case of a wrong date is not in range between 10-19 thus cannot be handled in trycatch block!
GO
ALTER PROCEDURE dbo.sp_rekord_werte
    @subscriber_id INT,
    @sensor_id INT ,
    @von_datum varchar,
    @bis_datum VARCHAR,
    @separate_messwerte BIT
=======
GO
ALTER PROCEDURE dbo.sp_rekord_werte
    @sensor_id INT = NULL,
    @von_datum char(8) = NULL,
    @bis_datum char(8) = NULL,
    @separate_messwerte BIT = NULL
>>>>>>> parent of d55c943... add error hanling
AS
BEGIN

    SET NOCOUNT ON;

    IF TRY_CONVERT(DATE,@von_datum) IS NULL
    BEGIN
    SELECT 50001 AS Fehlernummer, 'von Datum falsch' AS Fehlermeldung; 
    RETURN
    END
    ELSE IF TRY_CONVERT(DATE,@bis_datum) IS NULL
    BEGIN
    SELECT 50002 AS Fehlernummer, 'bis Datum falsch' AS Fehlermeldung;   
    RETURN
    END
    
<<<<<<< HEAD

    IF (SELECT COUNT(*) 
        FROM dbo.user_permission  
        WHERE @subscriber_id = subscriber_ID) = 0 --check if subscriber has permition to subscribe a sensor
    BEGIN
        SELECT 50003 AS Fehlernummer, CONCAT('Subscriber hat keine Zugriffsrechte auf Sensor :',CONVERT(INT,@sensor_id)) AS Fehlermeldung; 
        RETURN
    END
    ELSE IF (SELECT COUNT(*) 
            FROM dbo.user_permission 
            WHERE 1 = subscriber_ID AND (GETDATE() BETWEEN valid_from AND valid_to OR valid_to IS NULL))=0--CHECK if permition is still valid
    BEGIN
        SELECT 50004 AS Fehlernummer,CONCAT('Subscriber Zugriffsrecht abgelaufen fuer Sensor :', CONVERT(INT,@sensor_id)) AS Fehlermeldung; 
        RETURN
    END

    IF ( SELECT COUNT(*)
            FROM dbo.sensor sen
            INNER  JOIN dbo.measurement meas ON meas.sensor_ID = sen.sensor_ID
            WHERE (measure_time BETWEEN @von_datum AND @bis_datum) AND sen.sensor_ID = @sensor_id) = 0
    BEGIN
         SELECT 50004 AS Fehlernummer,CONCAT('Keine Messwerte vorhanden fuer Sensor:', @sensor_id,' zwischen ',@von_datum, ' und ',@bis_datum) AS Fehlermeldung; 
        RETURN
    END 
    
    
    BEGIN TRY
        
=======
    
    BEGIN TRY
        IF TRY_CONVERT(DATE,@von_datum) IS NULL
        BEGIN
        SELECT 'von Datum falsch' AS Result;   
        RETURN
        END
        ELSE IF TRY_CONVERT(DATE,@bis_datum) IS NULL
        BEGIN
        SELECT 'bis Datum falsch' AS Result;   
        RETURN
        END
        ELSE
>>>>>>> parent of d55c943... add error hanling

        BEGIN
            SELECT *
            FROM dbo.sensor sen
            INNER  JOIN dbo.measurement meas ON meas.sensor_ID = sen.sensor_ID
            WHERE (measure_time BETWEEN @von_datum AND @bis_datum) AND sen.sensor_ID = @sensor_id
            ORDER BY measure_time 
        END
       
    END TRY
    BEGIN CATCH
<<<<<<< HEAD
        SELECT ERROR_NUMBER() AS Fehlernummer, ERROR_MESSAGE() AS Fehlermeldung; -- default error
    END CATCH


    
END

EXEC dbo.sp_rekord_werte @subscriber_id = 1, @sensor_id = 1 ,@von_datum = '2018-12-01',@bis_datum = '2018-1-1',@separate_messwerte= 1


=======
        PRINT 'jajaj'
    END CATCH

    IF MONTH(@von_datum)>12
    BEGIN
        SELECT *
        FROM dbo.user_permission

    END

    
END
>>>>>>> parent of d55c943... add error hanling

EXEC dbo.sp_rekord_werte 1,'2018-1-20','2018-122-21',1

<<<<<<< HEAD
SELECT TRY_CONVERT([date], '12/31/2010') AS Result;  
SELECT COUNT(*) FROM dbo.user_permission per WHERE 1 = per.subscriber_ID AND per.valid_to IS NULL
=======
SELECT TRY_CONVERT([date], '12/31/2010') AS Result;  
>>>>>>> parent of d55c943... add error hanling
