
--The aim of the procedure is to add a new subscription, 
-- which enables a subscriber to read data from a couple of sensors via a channel. 
-- If a new subscription is inserted, a new CHANNEL and a correspond-ing SENSOR_GROUP entry is inserted as well. 
-- To identify which sensors are associated with a channel the table SENSOR_GROUP is significant.
-- A subscriber can have multiple channels, and each channel can have more than one sensor. During insertion process,
-- a trigger prevents the subscriber from creat-ing channels and attaching sensor without permission. 
-- This security feature allows to protect privacy, because subscribers are not able to add sensors from other subscribers.
-- Only administrators can change the sensor permission int the USER_PERMITION table. Another task of the stored procedure 
-- is to update an existing channel if it is expired.  

GO
CREATE PROCEDURE dbo.sp_subscribe_channel
    @subscriber_id INT,
    @channel_id INT = NULL,
    @valid_from_date char(40) = NULL,
    @valid_to_date char(40) = NULL,
    @channel_name varchar(32) = NULL,
    @channel_description varchar(255) = NULL,
    @sensor_ID_string varchar(255) = NULL,
    @sensor_ID_string_delimeter char(1) = NULL

AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @temp_channel_id INT
    DECLARE @count_ID_string INT --variable is needed for number of iterations in while loop

    --check if channel id IS NULL and channel name IS NULL -> channel ID IS NULL Means new subscription, NOT IS NULL --> update subscription
    IF (@channel_id IS NULL) AND (@channel_name IS NULL)
    BEGIN 
        SELECT 50100 AS ERRORNUMBER, 'If no channel ID is used as a parameter, channel name can not be empty' AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50100,'Empty channel ID');
        RETURN
    END
 
    --check if sensor_string or sensor id delimeter are empty. They can only be empty if the channel id is set
    IF (@sensor_ID_string IS NULL OR @sensor_ID_string_delimeter IS NULL) AND @channel_id IS NULL
    BEGIN
        SELECT 50107 AS ERRORNUMBER, 'sensor_ID_string and sensor_ID_string_delimeter can not be empty!' AS ERRORMESSAGE; 
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50107,'sensor_ID_string and sensor_ID_string_delimeter are empty');
        RETURN
    END

    --check if from_date or to_date is empty, if so write default date
    IF @valid_from_date IS NULL
        SET @valid_from_date = TRY_CONVERT(DATETIME2,GETDATE())AT TIME ZONE 'Central European Standard Time'
    
    IF @valid_to_date IS NULL
        SET @valid_to_date = TRY_CONVERT(DATETIME2,DATEADD(MONTH,12,GETDATE()))AT TIME ZONE 'Central European Standard Time'


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

    --check whether time difference between from- and to-date is greater 1 year
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
    --check if subscriber has a corresponding CHANNEL ID, if not could be a new channel or updating failed!
    IF (SELECT COUNT(*) 
            FROM dbo.subscription
            WHERE channel_id = @channel_id AND subscriber_ID = @subscriber_id) = 0 --no entry found --> new channel?
        AND NOT @channel_id IS NULL
    BEGIN
        SELECT 50107 AS ERRORNUMBER, 'Subscriber has no corresponding CHANNEL_ID' AS ERRORMESSAGE;
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50107,'Subscriber has no corresponding CHANNEL_ID'); 
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

             SELECT 50109 AS ERRORNUMBER, 'SUCCESS: updating channel' AS ERRORMESSAGE;
                    INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50109,'SUCCESS: updating channel'); 
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
            
            --insert into temporary table
            INSERT INTO #tempSensorIDs
            SELECT value FROM STRING_SPLIT(@sensor_ID_string,@sensor_ID_string_delimeter)

            
            WHILE(@count_ID_string>0)
            BEGIN
                --check if sensor exists in DB
                IF (SELECT COUNT(*) FROM dbo.sensor WHERE(sensor_ID = (SELECT TOP 1 id FROM #tempSensorIDs))) = 0
                BEGIN
                    SELECT 50108 AS ERRORNUMBER, CONCAT('Sensor does not exist ID: ',(SELECT TOP 1 id FROM #tempSensorIDs)) AS ERRORMESSAGE;
                    INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50108,CONCAT('Sensor does not exist ID: ',(SELECT TOP 1 id FROM #tempSensorIDs))); 
                    ROLLBACK TRANSACTION
                    RETURN
                END
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

             SELECT 50110 AS ERRORNUMBER, 'SUCCESS:  inserting subscription' AS ERRORMESSAGE;
                    INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',50110,'SUCCESS:  inserting subscription'); 
        
        END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        SELECT  ERROR_NUMBER() AS Fehlernummer, ERROR_MESSAGE() AS Fehlermeldung;  -- default error
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'sp_subscribe',ERROR_NUMBER(), ERROR_MESSAGE()); 
    END CATCH

END
