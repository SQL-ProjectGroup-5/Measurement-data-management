--subscriber is only able to create channel if at least ONE sensor is readable!
ALTER TRIGGER dbo.tg_channel_permission
ON dbo.subscription
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    --check if the subscriber has the permition to read at least ONE Sensor:
    -- if no sensor readable, creating an channel won't be adviceable
    
    -- IF(SELECT COUNT(*) FROM 
    -- (SELECT up.subscriber_ID, up.sensor_ID, up.valid_from, up.valid_to
    -- FROM dbo.user_permission up
    -- INNER JOIN inserted ins ON up.subscriber_ID = ins.subscriber_ID) AS tb) = 0
    -- BEGIN
    --     ROLLBACK TRANSACTION;
    --     THROW 50015, 'Subscriber hat keine Zugriffsrechte auf Sensor', 1;
    --     RETURN
    -- END

    SET NOCOUNT ON;
	DECLARE @subscriber int;
    	DECLARE @channel int;
    	SELECT TOP 1 @subscriber = subscriber_ID, @channel = channel_ID FROM inserted;
	IF ((SELECT count(*) FROM dbo.sensor_group sg left JOIN user_permission up ON sg.sensor_ID = up.sensor_ID WHERE sg.channel_id = @channel AND up.subscriber_ID = @subscriber) != (SELECT count(*) FROM dbo.sensor_group sg WHERE sg.channel_ID = @channel))
	BEGIN
		 ROLLBACK TRANSACTION;
         THROW 50300, 'Subscriber has no permition on Sensor', 1;
         RETURN
	END
    
    
END

