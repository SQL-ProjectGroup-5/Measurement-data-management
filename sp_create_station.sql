-- Returncode 1: Already existing location reused
-- Returncode 2: New location created
-- Returncode 3: Wrong parameters
-- Returncode 4: Wrong Location ID
-- Returncode 5: Unknown Error
CREATE PROCEDURE dbo.sp_create_station @name VARCHAR(255), @station_desc VARCHAR(255)=NULL, @location INT = NULL, @location_name VARCHAR(32) = NULL, @lat FLOAT = NULL, @long FLOAT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF @location IS NULL AND @lat IS NOT NULL AND @long IS NOT NULL
		BEGIN
			IF (SELECT COUNT(*) FROM dbo.location WHERE coordinates.STDistance(GEOGRAPHY::Point(@lat, @long, 4326)) < 10) > 0
			BEGIN
				SELECT @location = location_ID FROM dbo.location WHERE coordinates.STDistance(GEOGRAPHY::Point(@lat, @long, 4326)) < 10;
				INSERT INTO dbo.station (location_ID, name, description) VALUES (@location, @name, @station_desc);
				SELECT 1 AS 'STATUS';
			END ELSE
			BEGIN
				INSERT INTO dbo.location (name, coordinates) VALUES (ISNULL(@location_name,'location of' + @name), GEOGRAPHY::Point(@lat, @long, 4326));
				SET @location = @@IDENTITY;
				INSERT INTO dbo.station (location_ID, name, description) VALUES (@location, @name, @station_desc);
				SELECT 2 AS 'STATUS';
			END
		END ELSE IF @location IS NOT NULL
		BEGIN
			INSERT INTO dbo.station (location_ID, name,description) VALUES (@location, @name, @station_desc);
			SELECT 1 AS 'STATUS';
		END ELSE
		BEGIN
			SELECT 3 AS 'STATUS'
		END
	END TRY
	BEGIN CATCH
		IF ERROR_NUMBER() = 547
			SELECT 4 AS 'STATUS' ELSE
			SELECT 5 AS 'STATUS';
	END CATCH
END
