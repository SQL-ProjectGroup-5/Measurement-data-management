
--Error number:
--50011: 'Sensor mit ID ',@sensor_id,' nicht vorhanden!'
--50012: 'Subscriber hat keine Zugriffsrechte auf Sensor: ',@sensor_id
--50013: 'Subscriber Zugriffsrecht abgelaufen fuer Sensor: ', @sensor_id
--50014: 'von-Datum groesser als ist-Datum'
--50015: 'von Datum falsch'
--50016: 'bis Datum falsch'


SELECT * FROM dbo.subscriber
SELECT * FROM dbo.subscription
SELECT * FROM dbo.channel

GO

CREATE PROCEDURE dbo.sp_prj_subscribe
    @subscriber_id INT,
    @channel_id INT = NULL,
    @valid_from_date char(40),
    @valid_to_date char(40),
    @channel_name varchar(32) = NULL,
    @channel_description varchar(255) = NULL,
    @sensor_ID_string varchar(255),
    @sensor_ID_string_delimeter char(1)

AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @temp_channel_id INT
    DECLARE @count_ID_string INT --variable is needed for number of iterations in while loop

    --check if channel id IS NULL, if so, check if @channel_name and @channel_description are not null!
    IF @channel_id IS NULL AND (@channel_description IS NULL OR @channel_name IS NULL)
    BEGIN 
        SELECT 50100 AS ERRORNUMBER, 'If no channel ID is provided as a parameter, channel name and channel description can not be empty' AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50100,'Empty channel ID');
        
        RETURN
    END
    --check wether time difference between from- and to-date is greater 1 year
    IF DATEDIFF(MONTH,@valid_from_date,@valid_to_date) > 12
        BEGIN
            SELECT 50101 AS ERRORNUMBER, 'duration between from-date to to-date must not be greater than 1 year!' AS ERRORMESSAGE; 
            INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50101,'duration between from-date to to-date greater than 1 year!');
            RETURN
        END

    --check if subscriber id is in db
    IF (SELECT COUNT(*) FROM dbo.subscriber WHERE (subscriber_ID = @subscriber_id)) = 0
    BEGIN
        SELECT 50102 AS ERRORNUMBER, 'Subscriber ID not available' AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50102,'Subscriber ID not available');
        RETURN
    END
    --check if subscriber is linked to a channel, has to be checked otherwise an error will occur
    IF (SELECT COUNT(*) FROM dbo.subscription WHERE (subscriber_ID = @subscriber_id AND channel_ID = @channel_ID)) = 0
    BEGIN
        SELECT 50103 AS ERRORNUMBER, 'Subscriber ID is not linked to any channel!' AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50103,'Subscriber ID is not linked to any channel!');
        RETURN
    END
    
    --check if data format and input is incorrect:
    IF TRY_CONVERT(DATETIME2,@valid_from_date) IS NULL
    BEGIN
        SELECT 50104 AS ERRORNUMBER, 'wrong from-date format: yyyy-MM-dd hh:mm:ss +01:00' AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50104,'wrong from-date format');
        RETURN
    END
    ELSE IF TRY_CONVERT(DATETIME2,@valid_to_date) IS NULL
        BEGIN
        SELECT 50105 AS ERRORNUMBER, 'wrong to-date format: yyyy-MM-dd hh:mm:ss +01:00' AS ERRORMESSAGE;
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50105,'wrong from-date format'); 
    RETURN
    END
    ELSE IF @valid_from_date>@valid_to_date
    BEGIN
        SELECT 50106 AS ERRORNUMBER, 'from-date greater than to-date' AS ERRORMESSAGE;
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50106,'from-date greater than to-date'); 
        RETURN
    END


    --temporary table to store string values from procedure parameter
    CREATE TABLE #tempSensorIDs 
                (  
                    nr INT IDENTITY(1,1),
                    id INT
                )
    
    BEGIN TRY
    BEGIN TRANSACTION
        -- check if channel_id for subscriber_id already exists, if so, update valid_to_date!
        IF (SELECT COUNT(*) 
            FROM dbo.subscription
            WHERE channel_id = @channel_id AND subscriber_ID = @subscriber_id) > 0   
        BEGIN

            UPDATE dbo.subscription
            SET valid_from = @valid_from_date, valid_to = @valid_to_date
            WHERE(channel_ID = @channel_id AND subscriber_ID = @subscriber_id)

        END
        -- IF channel_id for subscriber_id does not exists try to insert new row into dbo.subsription, 
        --trigger tg_channel will start to check whether the user is allowed to subscribe a channel
        ELSE
        BEGIN
            INSERT INTO dbo.channel(channel.name,channel.[description]) 
            VALUES(@channel_name,@channel_description)
            SET @temp_channel_id = (SELECT TOP 1 channel_ID FROM dbo.channel ORDER BY channel_ID DESC) --get latest ID number 
            
            --insert new rows in sensor_group because a new channel is added with multiple senors (while loop needed)
            SET @count_ID_string = (SELECT COUNT(*) FROM STRING_SPLIT(@sensor_ID_string,@sensor_ID_string_delimeter))
            
            SELECT * FROM dbo.sensor_group
            --insert into temporary table
            INSERT INTO #tempSensorIDs
            SELECT value FROM STRING_SPLIT(@sensor_ID_string,@sensor_ID_string_delimeter)
            
            WHILE(@count_ID_string>0)
            BEGIN

                INSERT INTO dbo.sensor_group(channel_ID,sensor_ID,valid_from,valid_to)
                VALUES(@temp_channel_id,
                      (SELECT TOP 1 id FROM #tempSensorIDs),
                      @valid_from_date,
                      @valid_to_date)

                --each iteration delete first value
                DELETE FROM #tempSensorIDs WHERE (id=( SELECT TOP 1 id FROM #tempSensorIDs))
                SET @count_ID_string-=1
            END

            INSERT INTO dbo.subscription(subscription.subscriber_ID, subscription.channel_ID, subscription.valid_from, subscription.valid_to) --DML trigger will start here due to the INSERT statement
            VALUES(@subscriber_id, 
                @temp_channel_id,
                @valid_from_date,
                @valid_to_date)

            SELECT * FROM dbo.sensor_group
            
            --testing purpose:
            SELECT * FROM dbo.subscription
        END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        SELECT  ERROR_NUMBER() AS Fehlernummer, ERROR_MESSAGE() AS Fehlermeldung;  -- default error
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',ERROR_NUMBER(), ERROR_MESSAGE()); 
    END CATCH

END

--add a new channel with sensors
EXEC dbo.sp_prj_subscribe @subscriber_id = 2, @valid_from_date = '2018-11-20 00:00:00 +01:00', @valid_to_date = '2018-12-15 23:59:00 +01:00', 
                          @channel_description = 'a new one', @channel_name='bla bla',@sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'

--update channel (update valid from and valid to date)
EXEC dbo.sp_prj_subscribe @channel_id=1, @subscriber_id = 1, @valid_from_date = '2018-11-20 10:00:00 +01:00', @valid_to_date = '2018-12-15 23:59:00 +01:00', 
                          @sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'

                          SELECT COUNT(*) FROM dbo.subscription WHERE (subscriber_ID = 3 AND channel_ID = 2)
                          SELECT COUNT(*) 
            FROM dbo.subscription
            WHERE channel_id = 1 AND subscriber_ID = 1

SELECT * FROM dbo.user_permission
SELECT * FROM dbo.sensor_group
SELECT * FROM dbo.channel
SELECT * FROM dbo.subscription

--later maybe, turn valid_from and valid_to into optional parameters....
PRINT CONVERT(DATETIME2,GETDATE())AT TIME ZONE 'Central European Standard Time'

SELECT COUNT(*) FROM dbo.subscriber WHERE (subscriber_ID = 2)