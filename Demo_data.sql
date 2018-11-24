--Create station und location
INSERT INTO dbo.location (name) VALUES ('Testlocation'); -- point lass ich weg zum testen
INSERT INTO dbo.station (loc_id,name) VALUES (1,'Aussenstation');
--Create Type (bsp. Temperatur)
INSERT INTO dbo.[type] (name, [description],unit_long,unit_short) VALUES ('Aussentemperatur','Ein Testsensor','Celsius', '°C');
--Create Sensoren (2 Temperatursensoren)
INSERT INTO dbo.sensor (station_ID,type_ID,name,[description],max_difference,lower_bound,upper_bound) VALUES (1,1,'Ferienhaus', 'So warm ists im Ferienhaus', 10,-25,75);
INSERT INTO dbo.sensor (station_ID,type_ID,name,[description],max_difference,lower_bound,upper_bound) VALUES (1,1,'Garten', 'So warm ists im Garten', 2,-25,40);
--Create Messwert(Für jeden einen fiktiven)
INSERT INTO dbo.measurement (sensor_ID,value_orig,value_corrected) VALUES (1,-10,-9);
INSERT INTO dbo.measurement (sensor_ID,value_orig,value_corrected) VALUES (1,-9,-8);
INSERT INTO dbo.measurement (sensor_ID,value_orig,value_corrected) VALUES (2,-11,-8);
INSERT INTO dbo.measurement (sensor_ID,value_orig,value_corrected) VALUES (2,-10,-7);
--Create Subscriber (fiktive namen)
INSERT INTO dbo.subscriber (name,[description]) VALUES ('Sigismund','Das ist ein Test-Subscriber');
INSERT INTO dbo.subscriber (name,[description]) VALUES ('Gertrude','Das ist ein Test-Subscriber');
INSERT INTO dbo.subscriber (name,[description]) VALUES ('Fidelia','Das ist ein Test-Subscriber');
--Erlaube Subscriber 1 (die Sigismund) den Zugriff auf Sensor 1
INSERT INTO dbo.user_permission (subscriber_ID,sensor_ID) VALUES (1,1);
--Erstelle 2 Channels (einmal nur mit sensor 1, und einmal mit sensor 1 UND 2 (wegen Permissiontesting))
INSERT INTO dbo.channel (name, [description]) VALUES ('Ferienhaustemperatur','Dies ist der Kanal für alle Ferienhaustemperaturen');
INSERT INTO dbo.channel (name, [description]) VALUES ('Temperatur','Dies ist der Kanal für alle Temperaturen');
--Linke die 2 Channels zu den Sensoren
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (1,1); --Ferienhaustemperatur
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (2,1);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (2,2);
--Subscribe die Sigismund zum channel 1 (Ferienhaustemperatur)
INSERT INTO dbo.subscription (subscriber_ID,channel_ID) VALUES (1,1)

--Selects zum Testen
SELECT * FROM dbo.[location];
SELECT * FROM dbo.station;
SELECT * FROM dbo.[type];
SELECT * FROM dbo.channel;
SELECT * FROM dbo.sensor;
SELECT * FROM dbo.measurement;
SELECT * FROM dbo.sensor_group;
SELECT * FROM dbo.subscriber;

--wos is
