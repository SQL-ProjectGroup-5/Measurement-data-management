/*
This Trigger calculates the corrected value of a measurement if not already given. This is done by selecting the correction_function field from the sensor.
The given mathematical function is used to generate a SELECT statement which is executed and the resulting value is written to the value_orig field.
Since this trigger is executed every time a measurement comes in, the runtime is important. To minimize the time needed for execution, only the first value of an insert/update
is processed (TOP 1 FROM INSERTED). Due to this reason, no entries in the logging table are written.
*/
CREATE TRIGGER dbo.tg_calculate_corrected_value_iu ON dbo.measurement
FOR INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sensor INT;
	DECLARE @value_corrected FLOAT;
	DECLARE @value_corrected_from_sensor FLOAT;
	DECLARE @newtimestamp DATETIMEOFFSET;
	DECLARE @value_orig FLOAT;
	DECLARE @function NVARCHAR(MAX);
	DECLARE @parm NVARCHAR(50);
	SELECT TOP 1 @sensor = sensor_id, @value_orig = value_orig, @newtimestamp = measure_time, @value_corrected_from_sensor = value_corrected FROM inserted;
	IF (EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED) AND UPDATE(value_orig) AND NOT UPDATE(value_corrected))
	BEGIN
		IF ((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor) IS NOT NULL)
		BEGIN
			SET @function = (SELECT 'SELECT @value_corrected=' + REPLACE((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor), 'x', @value_orig) + ';');
			SET @parm = '@value_corrected float output'
			EXECUTE sp_executesql @function, @parm, @value_corrected OUT
			UPDATE dbo.measurement SET value_corrected = @value_corrected WHERE sensor_ID = @sensor AND measure_time = @newtimestamp;
		END ELSE IF ((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor) IS NULL)
		BEGIN
			UPDATE dbo.measurement SET value_corrected = @value_orig WHERE sensor_ID = @sensor AND measure_time = @newtimestamp;
		END
	END
	ELSE IF (EXISTS(SELECT * FROM INSERTED))
	BEGIN
		IF ((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor) IS NOT NULL AND @value_corrected_from_sensor IS NULL)
		BEGIN
			SET @function = (SELECT 'SELECT @value_corrected=' + REPLACE((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor), 'x', @value_orig) + ';');
			SET @parm = '@value_corrected float output'
			EXECUTE sp_executesql @function, @parm, @value_corrected OUT
			UPDATE dbo.measurement SET value_corrected = @value_corrected WHERE sensor_ID = @sensor AND measure_time = @newtimestamp;
		END ELSE IF ((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor) IS NULL AND @value_corrected_from_sensor IS NULL)
		BEGIN
			UPDATE dbo.measurement SET value_corrected = @value_orig WHERE sensor_ID = @sensor AND measure_time = @newtimestamp;
		END
	END 
END
GO
