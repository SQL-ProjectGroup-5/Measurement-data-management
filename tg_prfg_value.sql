--Performance?
CREATE TRIGGER dbo.measurmentValidation_i
ON dbo.measurement
INSTEAD OF insert
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @sensor int = (select sensor_id from inserted);
    DECLARE @lastvalue float = (select top 1 value_orig from dbo.measurement where sensor_id = @sensor AND invalid is null ORDER BY measure_time DESC);
    DECLARE @value float = (select top 1 value_orig from inserted);
    DECLARE @corr_value float = (select top 1 value_corrected from inserted);
    DECLARE @maxchange float = (select max_difference from dbo.sensor where sensor_id = @sensor);
    DECLARE @upper_bound float = (select upper_bound from dbo.sensor where sensor_id = @sensor);
    DECLARE @lower_bound float = (select lower_bound from dbo.sensor where sensor_id = @sensor);


    IF (ABS(@lastvalue-@value)<=@maxchange AND @value <= @upper_bound AND @value >= @lower_bound)
    BEGIN
        INSERT INTO dbo.measurement (sensor_ID,value_orig,value_corrected) VALUES (@sensor,@value,@corr_value);
    END
    ELSE
        INSERT INTO dbo.measurement (sensor_ID,value_orig,value_corrected,invalid) VALUES (@sensor,@value,@corr_value,1);
END
GO
