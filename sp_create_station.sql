-- Returncode 50200: INFORMATIONAL Already existing location reused
-- Returncode 50201: INFORMATIONAL New location created
-- Returncode 50203: Wrong parameters
-- Returncode 50204: Wrong Location ID
-- Returncode 50205: Unknown Error
CREATE PROCEDURE dbo.sp_create_station @name VARCHAR(255), @station_desc VARCHAR(255)=NULL, @location INT = NULL, @location_name VARCHAR(32) = NULL, @lat FLOAT = NULL, @long FLOAT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
		IF @location IS NULL AND @lat IS NOT NULL AND @long IS NOT NULL
		BEGIN
			IF (SELECT COUNT(*) FROM dbo.location WHERE coordinates.STDistance(GEOGRAPHY::Point(@lat, @long, 4326)) < 10) > 0
			BEGIN
				SELECT @location = location_ID FROM dbo.location WHERE coordinates.STDistance(GEOGRAPHY::Point(@lat, @long, 4326)) < 10;
				INSERT INTO dbo.station (location_ID, name, description) VALUES (@location, @name, @station_desc);
				SELECT 50200 AS ERRORCODE, 'Successful INFO: Already existing location reused' AS ERRORMESSAGE;
				COMMIT;
			END ELSE
			BEGIN
				INSERT INTO dbo.location (name, coordinates) VALUES (ISNULL(@location_name,'location of' + @name), GEOGRAPHY::Point(@lat, @long, 4326));
				SET @location = @@IDENTITY;
				INSERT INTO dbo.station (location_ID, name, description) VALUES (@location, @name, @station_desc);
				SELECT 50201 AS ERRORCODE, 'Successful INFO: New location created' AS ERRORMESSAGE;
				COMMIT;
			END
		END ELSE IF @location IS NOT NULL
		BEGIN
			INSERT INTO dbo.station (location_ID, name,description) VALUES (@location, @name, @station_desc);
			SELECT 50200 AS ERRORCODE, 'Successful INFO: Already existing location reused' AS ERRORMESSAGE;
			COMMIT;
		END ELSE
		BEGIN
			SELECT 50203 AS ERRORCODE, 'Invalid parameters' AS ERRORMESSAGE;
			ROLLBACK;
		END
	END TRY
	BEGIN CATCH
	ROLLBACK;
		IF ERROR_NUMBER() = 547
			SELECT 50204 AS ERRORCODE, 'Wrong location ID' AS ERRORMESSAGE; ELSE
			SELECT 50205 AS ERRORCODE, 'Unknown error' AS ERRORMESSAGE;
	END CATCH
END
