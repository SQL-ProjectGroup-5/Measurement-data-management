--The permission check trigger (aka “tg_channel_permission_IU”) 
--is linked to the subscription table and will start if INSERT or 
--UPDATE statements are executed. It supports the procedure “sp_subscribe_channel” 
--and checks if a user has permission to subscribe a sensor. The trigger can-cels the transaction, 
--in addition to that, the creating-channel-process will be rolled back.

CREATE TRIGGER dbo.tg_channel_permission_IU
ON dbo.subscription
AFTER INSERT, UPDATE
AS
BEGIN

    SET NOCOUNT ON;
	DECLARE @subscriber int;
    	DECLARE @channel int;
    	SELECT TOP 1 @subscriber = subscriber_ID, @channel = channel_ID FROM inserted;
    
    --compare the amount of sensors with permission to the amount of sensors linked to the subscribed channel
    --a difference between means the subscriber is not allowed to read all sensors.
	IF ((SELECT count(*) FROM dbo.sensor_group sg left JOIN user_permission up ON sg.sensor_ID = up.sensor_ID 
        WHERE sg.channel_id = @channel AND up.subscriber_ID = @subscriber) 
        != (SELECT count(*) FROM dbo.sensor_group sg WHERE sg.channel_ID = @channel))
	BEGIN
		ROLLBACK TRANSACTION;
        THROW 50300, 'Subscriber has no permission to read all sensors linked to the channel', 1;
        INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(),'tg_channel_permission', 50300, 'Subscriber has no permission to read all sensors linked to the channel'); 
        RETURN
	END
    
END




SELECT * FROM db.logging