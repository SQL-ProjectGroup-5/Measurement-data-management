-- Returncode 50200: INFORMATIONAL Already existing location reused
-- Returncode 50201: INFORMATIONAL New location created
-- Returncode 50203: Wrong parameters
-- Returncode 50204: Wrong Location ID
-- Returncode 50204: Station name has to be unique
-- Returncode 50206: Unknown Error
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
				INSERT INTO dbo.logging (causing_user, involved_procedure, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_create_station',50200,'Successful INFO: Already existing location reused');
				COMMIT;
			END ELSE
			BEGIN
				INSERT INTO dbo.location (name, coordinates) VALUES (ISNULL(@location_name,'location of' + @name), GEOGRAPHY::Point(@lat, @long, 4326));
				SET @location = @@IDENTITY;
				INSERT INTO dbo.station (location_ID, name, description) VALUES (@location, @name, @station_desc);
				SELECT 50201 AS ERRORCODE, 'Successful INFO: New location created' AS ERRORMESSAGE;
				INSERT INTO dbo.logging (causing_user, involved_procedure, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_create_station',50201,'Successful INFO: New location created');
				COMMIT;
			END
		END ELSE IF @location IS NOT NULL
		BEGIN
			INSERT INTO dbo.station (location_ID, name,description) VALUES (@location, @name, @station_desc);
			SELECT 50200 AS ERRORCODE, 'Successful INFO: Already existing location reused' AS ERRORMESSAGE;
			INSERT INTO dbo.logging (causing_user, involved_procedure, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_create_station',50200,'Successful INFO: Already existing location reused');
			COMMIT;
		END ELSE
		BEGIN
			SELECT 50203 AS ERRORCODE, 'Invalid parameters' AS ERRORMESSAGE;
			ROLLBACK;
			INSERT INTO dbo.logging (causing_user, involved_procedure, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_create_station',50203,'Invalid parameters');
		END
	END TRY
	BEGIN CATCH
	ROLLBACK;
		IF ERROR_NUMBER() = 547
		BEGIN
			SELECT 50204 AS ERRORCODE, 'Wrong location ID' AS ERRORMESSAGE;
			INSERT INTO dbo.logging (causing_user, involved_procedure, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_create_station',50204,'Wrong location ID');
		END
		ELSE IF ERROR_NUMBER() = 2627
		BEGIN
			SELECT 50205 AS ERRORCODE, 'Station name has to be unique' AS ERRORMESSAGE;
			INSERT INTO dbo.logging (causing_user, involved_procedure, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_create_station',50205,'Station name has to be unique');
		END
		ELSE
		BEGIN
			SELECT 50206 AS ERRORCODE, 'Unknown error' AS ERRORMESSAGE; 
			INSERT INTO dbo.logging (causing_user, involved_procedure, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_create_station',50206,'Unknown error');
		END
	END CATCH
END
