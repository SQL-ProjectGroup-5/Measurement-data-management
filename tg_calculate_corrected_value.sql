/*
This Trigger calculates the corrected value of a measurement if not already given. This is done by selecting the correction_function field from the sensor.
The given mathematical function is used to generate a SELECT statement which is executed and the resulting value is written to the value_orig field.
Since this trigger is executed every time a measurement comes in, the runtime is important. To minimize the time needed for execution, only the first value of an insert
is processed (TOP 1 FROM INSERTED). Due to this reason, no entries in the logging table are written.
*/
CREATE TRIGGER dbo.tg_calculate_corrected_value_i
ON dbo.measurement
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @sensor int;
    DECLARE @value_corrected float;
	DECLARE @value_corrected_from_sensor float;
    DECLARE @newtimestamp DATETIMEOFFSET;
    DECLARE @value_orig float;
    SELECT TOP 1 @sensor = sensor_id, @value_orig = value_orig, @newtimestamp = measure_time, @value_corrected_from_sensor = value_corrected FROM inserted;
	IF ((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor) IS NOT NULL AND @value_corrected_from_sensor IS NULL)
	BEGIN 
		DECLARE @function NVARCHAR(MAX) = (SELECT 'SELECT @value_corrected=' + REPLACE((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor),'x',@value_orig) +';');
		DECLARE @parm NVARCHAR(50) = '@value_corrected float output'
		EXECUTE sp_executesql @function, @parm, @value_corrected OUT
		UPDATE dbo.measurement SET value_corrected = @value_corrected WHERE sensor_ID = @sensor AND measure_time = @newtimestamp;
    END
	ELSE IF ((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor) IS NULL AND @value_corrected_from_sensor IS NULL)
	BEGIN
		UPDATE dbo.measurement SET value_corrected = @value_orig WHERE sensor_ID = @sensor AND measure_time = @newtimestamp;
	END
END
GO
