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
UPDATE dbo.measurement SET value_orig = 13.3 WHERE sensor_ID=10 AND measure_time = '2018-11-01 17:25:00.0000000 +01:00'; -- This invalidates the measurement since the value now violates the sensor's specification
SELECT * FROM dbo.measurement where sensor_ID=10 AND measure_time = '2018-11-01 17:25:00.0000000 +01:00';
GO
UPDATE dbo.measurement SET value_orig = 23.23 WHERE sensor_ID=10 AND measure_time = '2018-11-01 17:25:00.0000000 +01:00'; -- This revalidates the measurement since the value no longer violates the sensor's specification
SELECT * FROM dbo.measurement where sensor_ID=10 AND measure_time = '2018-11-01 17:25:00.0000000 +01:00';
GO
