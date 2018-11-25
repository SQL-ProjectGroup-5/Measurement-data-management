-- Zeigt alle Sensoren und Stationen an
SELECT se.sensor_ID, st.name, se.name FROM dbo.sensor se JOIN dbo.station st ON st.station_ID=se.station_ID;
