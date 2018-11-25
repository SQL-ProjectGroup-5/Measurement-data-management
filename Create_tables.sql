
--DROP TABLE dbo.sensor_group;
--DROP TABLE dbo.user_permission;
--DROP TABLE dbo.subscription;
--DROP TABLE dbo.measurement;
--DROP TABLE dbo.sensor;
--DROP TABLE dbo.station;
--DROP TABLE dbo.channel;
--DROP TABLE dbo.subscriber;
--DROP TABLE dbo.type;
--DROP TABLE dbo.location;

CREATE TABLE dbo.location (
    location_ID int IDENTITY(1,1),
    name varchar(32) NOT NULL,
    coordinates GEOGRAPHY, -- WSL PFUSCH CONSTRAINT FEHLT
    CONSTRAINT PK_location_ID PRIMARY KEY (location_ID)
);
CREATE TABLE dbo.type(
    type_ID int IDENTITY(1,1),
    name varchar(32) NOT NULL,
    description VARCHAR(255),
    unit_long varchar(32),
    unit_short VARCHAR(32),
    CONSTRAINT PK_type_id PRIMARY KEY (type_ID)
);
CREATE TABLE dbo.subscriber(
    subscriber_ID int IDENTITY(1,1),
    name varchar(32) NOT NULL,
    description varchar(255),
    pwd varchar(255),
    CONSTRAINT PK_subscriber_ID PRIMARY KEY (subscriber_ID)
);
CREATE TABLE dbo.channel(
    channel_ID int IDENTITY(1,1),
    name varchar(32) NOT NULL,
    description varchar(255),
    CONSTRAINT PK_channel_ID PRIMARY KEY (channel_ID)
);
CREATE TABLE dbo.station (
    station_ID int IDENTITY(1,1),
    location_ID int NOT NULL,
    name varchar(32) NOT NULL,
    description varchar(255),
    CONSTRAINT PK_station_ID PRIMARY KEY (station_ID),
    CONSTRAINT FK_locationStation_ID FOREIGN KEY (location_ID) REFERENCES dbo.location(location_ID)
);
CREATE TABLE dbo.sensor (
    sensor_ID int IDENTITY(1,1),
    station_ID INT NOT NULL,
    type_ID INT NOT NULL,
    name VARCHAR(32) NOT NULL,
    description varchar(255),
    valid bit not NULL DEFAULT 1,
    correction_function VARCHAR(32),
    conversion_function VARCHAR(32),
    valid_from DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME2,
    max_difference float,
    lower_bound float,
    upper_bound float,
    CONSTRAINT PK_sensor_id PRIMARY KEY (sensor_ID),
    CONSTRAINT FK_sensor_station FOREIGN KEY (station_ID) REFERENCES dbo.station (station_ID),
    CONSTRAINT FK_sensor_type FOREIGN KEY (type_ID) REFERENCES dbo.type (type_ID)
);
CREATE TABLE dbo.measurement (
    sensor_ID INT NOT NULL,
    measure_time DATETIMEOFFSET NOT NULL DEFAULT CURRENT_TIMESTAMP,
    value_orig FLOAT NOT NULL,
    value_corrected FLOAT NOT NULL,
    invalid bit,
    CONSTRAINT PK_sensor_time PRIMARY KEY (sensor_ID,measure_time),
    CONSTRAINT FK_measurement_sensor FOREIGN KEY (sensor_ID) REFERENCES dbo.sensor(sensor_ID) 
);
-- seltsame identifizierende magische beziehungen die keiner ganz versteht
CREATE TABLE dbo.subscription(
    subscriber_ID INT NOT NULL,
    channel_ID INT NOT NULL,
    valid_from DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME2,
    CONSTRAINT FK_subscriptionSubscriber_ID FOREIGN KEY (subscriber_ID) REFERENCES dbo.subscriber(subscriber_ID), 
    CONSTRAINT FK_subscriptionChannel_ID FOREIGN KEY (channel_ID) REFERENCES dbo.channel(channel_ID),
    CONSTRAINT PK_subcriber_channel PRIMARY KEY (subscriber_ID, channel_ID)
);

CREATE TABLE dbo.user_permission(
    subscriber_ID INT NOT NULL,
    sensor_ID INT NOT NULL,
    valid_from DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME2,
    CONSTRAINT FK_permissionSubscriber_ID FOREIGN KEY (subscriber_ID) REFERENCES dbo.subscriber(subscriber_ID), 
    CONSTRAINT FK_permissionSensor_ID FOREIGN KEY (sensor_ID) REFERENCES dbo.sensor(sensor_ID),
    CONSTRAINT PK_subcriber_sensor PRIMARY KEY (subscriber_ID, sensor_ID)
);

CREATE TABLE dbo.sensor_group(
    channel_ID INT NOT NULL,
    sensor_ID INT NOT NULL,
    valid_from DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME2,
    CONSTRAINT FK_groupChannel_ID FOREIGN KEY (channel_ID) REFERENCES dbo.channel(channel_ID), 
    CONSTRAINT FK_groupSensor_ID FOREIGN KEY (sensor_ID) REFERENCES dbo.sensor(sensor_ID),
    CONSTRAINT PK_channel_sensor PRIMARY KEY (channel_ID, sensor_ID)
);
-- ende der seltsamen magischen beziehungen
