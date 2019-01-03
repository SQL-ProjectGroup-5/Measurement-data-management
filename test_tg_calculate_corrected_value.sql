INSERT INTO dbo.measurement (sensor_ID,value_orig) VALUES (1,71);
SELECT TOP 1 * FROM dbo.measurement ORDER BY measure_time DESC; -- Shows that the original value is increased by 0.1 and written to the corrected field
GO
INSERT INTO dbo.measurement (sensor_ID,value_orig) VALUES (2,70);
SELECT TOP 1 * FROM dbo.measurement ORDER BY measure_time DESC; -- Since no correction function is given, the value is just copied over to the corrected field
GO
INSERT INTO dbo.measurement (sensor_ID,value_orig, value_corrected) VALUES (2,70,72);
SELECT TOP 1 * FROM dbo.measurement ORDER BY measure_time DESC; -- No calculation is performed when the corrected value is already given
GO
UPDATE dbo.measurement SET value_orig = 95 WHERE sensor_ID=1 AND measure_time = '2018-11-02 08:20:00.0000000 +01:00'; -- The corrected value is recalculated since the original value has changed
SELECT * FROM dbo.measurement where sensor_ID=1 AND measure_time = '2018-11-02 08:20:00.0000000 +01:00';
GO
UPDATE dbo.measurement SET value_orig=94, value_corrected = 94  WHERE sensor_ID=1 AND measure_time = '2018-11-02 08:20:00.0000000 +01:00'; -- The corrected value is not recalculated since the corrected value is given during the update
SELECT * FROM dbo.measurement where sensor_ID=1 AND measure_time = '2018-11-02 08:20:00.0000000 +01:00';
GO
