--Create station und location
INSERT INTO dbo.location (name) VALUES ('Testlocation'); -- point lass ich weg zum testen
GO
INSERT INTO dbo.station (location_ID,name) VALUES (1,'WS2301');
GO
INSERT INTO dbo.station (location_ID,name) VALUES (1,'WS2302');
GO
--Create Type (bsp. Temperatur)
INSERT INTO dbo.[type] (name, [description],unit_long,unit_short) VALUES ('Temperatur','Typ fuer alle Temperatursensoren','Celsius', '°C');
GO
INSERT INTO dbo.[type] (name, [description],unit_long,unit_short) VALUES ('Luftfeuchte','Typ fuer alle Feuchtigkeitssensoren','Prozent', '%');
GO
INSERT INTO dbo.[type] (name, [description],unit_long,unit_short) VALUES ('Luftdruck','Typ fuer alle Luftdrucksensoren','Hektopascal', 'hPa');
GO
--Create Sensoren (2 Temperatursensoren)
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (1,2,'Luftfeuchtigkeit draussen', 100,0,100);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (1,2,'Luftfeuchtigkeit drinnen', 100,0,100);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (1,3,'Luftdruck absolut', 250,77,1100);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (1,1,'Temperatur draussen', 4,-25,45);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (1,1,'Temperatur drinnen', 7,0,35);
GO
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (2,2,'Luftfeuchtigkeit draussen', 100,0,100);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (2,2,'Luftfeuchtigkeit drinnen', 100,0,100);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (2,3,'Luftdruck absolut', 250,77,1100);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (2,1,'Temperatur draussen', 4,-25,45);
INSERT INTO dbo.sensor (station_ID,type_ID,name,max_difference,lower_bound,upper_bound) VALUES (2,1,'Temperatur drinnen', 7,0,35);
GO
--Create Subscriber (fiktive namen)
INSERT INTO dbo.subscriber (name,[description]) VALUES ('Sigismund','Das ist ein Test-Subscriber');
INSERT INTO dbo.subscriber (name,[description]) VALUES ('Gertrude','Das ist ein Test-Subscriber');
INSERT INTO dbo.subscriber (name,[description]) VALUES ('Fidelia','Das ist ein Test-Subscriber');
GO
--Erlaube Subscriber 1 (die Sigismund) den Zugriff auf alle Temperatursensoren
INSERT INTO dbo.user_permission (subscriber_ID,sensor_ID) VALUES (1,4);
INSERT INTO dbo.user_permission (subscriber_ID,sensor_ID) VALUES (1,5);
INSERT INTO dbo.user_permission (subscriber_ID,sensor_ID) VALUES (1,9);
INSERT INTO dbo.user_permission (subscriber_ID,sensor_ID) VALUES (1,10);
GO
--Erstelle 2 Channels (einmal nur mit Temperatursensoren, und einmal mit allen Sensoren der WS2301 (wegen Permissiontesting))
INSERT INTO dbo.channel (name, [description]) VALUES ('Temperaturen','Dies ist der Kanal für alle Temperaturen');
INSERT INTO dbo.channel (name, [description]) VALUES ('WS2301','Dies ist der Kanal für alle Sensoren der WS2301');
GO
--Linke die 2 Channels zu den Sensoren
-- Alle Temperaturen
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (1,4);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (1,5);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (1,9);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (1,10);
GO
-- Alle WS2301 Sensoren
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (2,1);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (2,2);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (2,3);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (2,4);
INSERT INTO dbo.sensor_group (channel_ID,sensor_ID) VALUES (2,5);
GO
--Subscribe die Sigismund zum channel 1 (Alle Temperaturen)
INSERT INTO dbo.subscription (subscriber_ID,channel_ID) VALUES (1,1)
GO
--Selects zum Testen
SELECT * FROM dbo.[location];
SELECT * FROM dbo.station;
SELECT * FROM dbo.[type];
SELECT * FROM dbo.channel;
SELECT * FROM dbo.sensor;
SELECT * FROM dbo.measurement;
SELECT * FROM dbo.sensor_group;
SELECT * FROM dbo.subscriber;
