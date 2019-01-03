INSERT INTO dbo.measurement (sensor_ID,value_orig) VALUES (2,65);
SELECT TOP 1 * FROM dbo.measurement ORDER BY measure_time DESC; -- This is a correct value
GO
INSERT INTO dbo.measurement (sensor_ID,value_orig) VALUES (2,85);
SELECT TOP 1 * FROM dbo.measurement ORDER BY measure_time DESC; -- This is invalid, since the difference is > 10
GO
INSERT INTO dbo.measurement (sensor_ID,value_orig) VALUES (2,150);
GO
INSERT INTO dbo.measurement (sensor_ID,value_orig) VALUES (2,-127);
SELECT TOP 2 * FROM dbo.measurement ORDER BY measure_time DESC; -- Both measurements are invalid since they are out of range
GO
