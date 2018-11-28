CREATE TRIGGER dbo.calculate_corrected_value_iu
ON dbo.measurement
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @sensor int;
    DECLARE @value_corrected float;
    DECLARE @newtimestamp DATETIMEOFFSET;
    DECLARE @value_orig float;
    SELECT TOP 1 @sensor = sensor_id, @value_orig = value_orig, @newtimestamp = measure_time FROM inserted; 


    DECLARE @function NVARCHAR(MAX) = (SELECT 'SELECT @value_corrected=' + REPLACE((SELECT correction_function FROM dbo.sensor WHERE sensor_ID = @sensor),'x',@value_orig) +';');
    PRINT @function;
    DECLARE @parm NVARCHAR(50) = '@value_corrected float output'
    EXECUTE sp_executesql @function, @parm, @value_corrected OUT
    UPDATE dbo.measurement SET value_corrected = @value_corrected WHERE sensor_ID = @sensor AND measure_time = @newtimestamp;
    
END
GO
