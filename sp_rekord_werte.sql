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
FROM dbo.measurement;
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
-- Datum wurde im falschen Format übergeben: dd.mm.yyyy
GO
CREATE PROCEDURE dbo.sp_rekord_werte
    @sensor_id INT = NULL,
    @von_datum DATE = NULL,
    @bis_datum DATE = NULL,
    @separat_messwerte BIT = NULL
AS
BEGIN

    SET NOCOUNT ON;



END
