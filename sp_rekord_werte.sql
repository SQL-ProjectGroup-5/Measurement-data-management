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
GO
ALTER PROCEDURE dbo.sp_rekord_werte
    @sensor_id INT = NULL,
    @von_datum char(8) = NULL,
    @bis_datum char(8) = NULL,
    @separate_messwerte BIT = NULL
AS
BEGIN

    SET NOCOUNT ON;
    
    
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

        BEGIN
            SELECT *
            FROM dbo.sensor sen
            INNER  JOIN dbo.measurement meas ON meas.sensor_ID = sen.sensor_ID
            WHERE (measure_time BETWEEN @von_datum AND @bis_datum) AND sen.sensor_ID = @sensor_id
            ORDER BY measure_time 
        END
       
    END TRY
    BEGIN CATCH
        PRINT 'jajaj'
    END CATCH

    IF MONTH(@von_datum)>12
    BEGIN
        SELECT *
        FROM dbo.user_permission

    END

    
END

EXEC dbo.sp_rekord_werte 1,'2018-1-20','2018-122-21',1

SELECT TRY_CONVERT([date], '12/31/2010') AS Result;  