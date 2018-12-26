-- Returncode 1: Already existing location reused
-- Returncode 2: New location created
-- Returncode 3: Error
CREATE PROCEDURE dbo.sp_create_station @name VARCHAR(255), @lat FLOAT, @long FLOAT
AS
BEGIN
	DECLARE @location INT;
	BEGIN TRY
		IF (SELECT COUNT(*) FROM dbo.location WHERE coordinates.STDistance(GEOGRAPHY::Point(@lat, @long, 4326)) < 10) > 0
		BEGIN
			SELECT @location = location_ID FROM dbo.location WHERE coordinates.STDistance(GEOGRAPHY::Point(@lat, @long, 4326)) < 10;
			INSERT INTO dbo.station (location_ID, name) VALUES (@location, @name);
			SELECT 1 AS 'STATUS';
		END ELSE
		BEGIN
			INSERT INTO dbo.location (name, coordinates) VALUES ('location of' + @name, GEOGRAPHY::Point(@lat, @long, 4326));
			SET @location = @@IDENTITY;
			INSERT INTO dbo.station (location_ID, name) VALUES (@location, @name);
			SELECT 2 AS 'STATUS';
		END
	END TRY
	BEGIN CATCH
		SELECT 3 AS 'STATUS';
	END CATCH
END
