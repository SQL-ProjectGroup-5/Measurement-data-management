CREATE TABLE dbo.location (
    loc_ID int IDENTITY(1,1),
    name varchar(32) NOT NULL,
    coordinates GEOGRAPHY, -- WSL PFUSCH CONSTRAINT FEHLT
    CONSTRAINT PK_location_ID PRIMARY KEY (loc_ID)
);
CREATE TABLE dbo.type(
    type_ID int IDENTITY(1,1),
    name varchar(32) NOT NULL,
    description VARCHAR(255),
    unit_long varchar(32),
    unit_short VARCHAR(32),
    CONSTRAINT PK_type_id PRIMARY KEY (type_ID)
);
CREATE TABLE subscriber(
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
    stat_ID int IDENTITY(1,1),
    loc_ID int NOT NULL,
    name varchar(32) NOT NULL,
    description varchar(255),
    CONSTRAINT PK_station_ID PRIMARY KEY (stat_ID),
    CONSTRAINT FK_locationStation_ID FOREIGN KEY (loc_ID) REFERENCES dbo.location(loc_ID)
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
    valid_from DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME,
    max_difference float,
    lower_bound float,
    upper_bound float,
    CONSTRAINT PK_sensor_id PRIMARY KEY (sensor_ID),
    CONSTRAINT FK_sensor_station FOREIGN KEY (station_ID) REFERENCES dbo.station (stat_ID),
    CONSTRAINT FK_sensor_type FOREIGN KEY (type_ID) REFERENCES dbo.type (type_ID)
);
CREATE TABLE dbo.measurement (
    measurement_ID int IDENTITY(1,1),
    sensor_ID INT NOT NULL,
    measure_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    value_orig FLOAT NOT NULL,
    value_corrected FLOAT NOT NULL,
    CONSTRAINT PK_measurement_ID PRIMARY KEY (measurement_ID),
    CONSTRAINT FK_measurement_sensor FOREIGN KEY (sensor_ID) REFERENCES dbo.sensor(sensor_ID) 
);
-- seltsame identifizierende magische beziehungen die keiner ganz versteht
CREATE TABLE subscription(
    subscriber_ID INT NOT NULL,
    channel_ID INT NOT NULL,
    valid_from DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME,
    CONSTRAINT FK_subscriptionSubscriber_ID FOREIGN KEY (subscriber_ID) REFERENCES dbo.subscriber(subscriber_ID), 
    CONSTRAINT FK_subscriptionChannel_ID FOREIGN KEY (channel_ID) REFERENCES dbo.channel(channel_ID),
    CONSTRAINT PK_subcriber_channel PRIMARY KEY (subscriber_ID, channel_ID)
);

CREATE TABLE user_permission(
    subscriber_ID INT NOT NULL,
    sensor_ID INT NOT NULL,
    valid_from DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME,
    CONSTRAINT FK_permissionSubscriber_ID FOREIGN KEY (subscriber_ID) REFERENCES dbo.subscriber(subscriber_ID), 
    CONSTRAINT FK_permissionSensor_ID FOREIGN KEY (sensor_ID) REFERENCES dbo.sensor(sensor_ID),
    CONSTRAINT PK_subcriber_sensor PRIMARY KEY (subscriber_ID, sensor_ID)
);

CREATE TABLE sensor_group(
    channel_ID INT NOT NULL,
    sensor_ID INT NOT NULL,
    valid_from DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to DATETIME,
    CONSTRAINT FK_groupChannel_ID FOREIGN KEY (channel_ID) REFERENCES dbo.channel(channel_ID), 
    CONSTRAINT FK_groupSensor_ID FOREIGN KEY (sensor_ID) REFERENCES dbo.sensor(sensor_ID),
    CONSTRAINT PK_channel_sensor PRIMARY KEY (channel_ID, sensor_ID)
);
-- ende der seltsamen magischen beziehungen
