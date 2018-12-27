--Performance?
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
    END
    ELSE
    BEGIN
        IF @lasttimestamp IS NOT NULL AND DATEDIFF(minute,@lasttimestamp,@newtimestamp) <= 180
        BEGIN
            IF (ABS(@lastvalue-@value)>=@maxchange)
            BEGIN
                UPDATE dbo.measurement SET invalid = 1 WHERE sensor_ID = @sensor and measure_time = @newtimestamp;
            END
        END
    END
END
GO
