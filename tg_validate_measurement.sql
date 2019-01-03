/*
This trigger validates the value of a measurement. If a value is valid is determined by the difference to the last valid value (only valid values which are not older than 180 minutes are checked)
and by the upper and lower bound. These parameters are specified by the sensor. When an value is invalid, the invalid flag is set on this measurement. Furthermore a entry in the logging table is created.
Like the tg_calculate_corrected_value trigger, this trigger is executed each time an measurement comes in. Therefore the same measures to minimize runtime (SELECT TOP 1...) are taken. 
The trigger uses the followig returncodes, which are only written to the logging table:

-- Returncode 50400: Set invalid bit because measurement is out of range
-- Returncode 50401: Set invalid bit because max change within timeframe is exceeded
*/
CREATE TRIGGER dbo.tg_validate_measurement_i
ON dbo.measurement
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @sensor int;
    DECLARE @lastvalue float;
    DECLARE @lasttimestamp datetimeoffset;
    DECLARE @value float;
    DECLARE @corr_value float;
    DECLARE @maxchange float;
    DECLARE @upper_bound float;
    DECLARE @lower_bound float;
    DECLARE @newtimestamp DATETIMEOFFSET;
    SELECT TOP 1 @sensor = sensor_id, @value = value_orig, @corr_value = value_corrected, @newtimestamp = measure_time FROM inserted; 
    SELECT @maxchange=max_difference, @upper_bound=upper_bound, @lower_bound=lower_bound from dbo.sensor where sensor_id = @sensor;

    SELECT TOP 1 @lastvalue=A.value_orig, @lasttimestamp=A.measure_time 
    FROM dbo.measurement A 
    WHERE A.measure_time != @newtimestamp AND A.invalid IS NULL AND A.sensor_ID = @sensor 
    ORDER BY A.measure_time DESC;

    IF NOT @value BETWEEN @lower_bound AND @upper_bound
    BEGIN
        UPDATE dbo.measurement SET invalid = 1 WHERE sensor_ID = @sensor and measure_time = @newtimestamp;
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'tg_validate_measurement_i',50400,'Set invalid bit because measurement is out of range');
    END
    ELSE
    BEGIN
        IF @lasttimestamp IS NOT NULL AND DATEDIFF(minute,@lasttimestamp,@newtimestamp) <= 180
        BEGIN
            IF (ABS(@lastvalue-@value)>=@maxchange)
            BEGIN
                UPDATE dbo.measurement SET invalid = 1 WHERE sensor_ID = @sensor and measure_time = @newtimestamp;
				INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'tg_validate_measurement_i',50401,'Set invalid bit because max change within timeframe is exceeded');
            END
        END
    END
END
GO
