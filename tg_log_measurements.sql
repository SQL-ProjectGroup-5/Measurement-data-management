/*
This is a small log trigger which is used to keep a history of old measurements.
The trigger uses the followig returncode, which are only written to the logging table:

-- Returncode 50403: Original Value was changed
*/
CREATE TRIGGER dbo.tg_log_measurement ON dbo.measurement
FOR UPDATE
AS
BEGIN
	IF (UPDATE (value_orig))
		DECLARE @oldvalue VARCHAR(32);
		DECLARE @timestamp VARCHAR(64);
		DECLARE @sensor VARCHAR(10);
		SELECT TOP 1 @oldvalue = value_orig, @timestamp = measure_time, @sensor = sensor_id FROM INSERTED;
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(), 'tg_log_measurement', 50403, 'Original value of measurement was updated Sensor: ' + @sensor + ' Timestamp: ' + @timestamp + ' Original Value: ' + @oldvalue);
END
