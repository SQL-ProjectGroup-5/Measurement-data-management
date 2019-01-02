--subscriber is only able to create channel if at least ONE sensor is readable!
ALTER TRIGGER dbo.tg_channel_permission
ON dbo.subscription
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    --check if the subscriber has the permition to read at least ONE Sensor:
    -- if no sensor readable, creating an channel won't be adviceable
    
    IF(SELECT COUNT(*) FROM 
    (SELECT up.subscriber_ID, up.sensor_ID, up.valid_from, up.valid_to
    FROM dbo.user_permission up
    INNER JOIN inserted ins ON up.subscriber_ID = ins.subscriber_ID) AS tb) = 0
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50015, 'Subscriber hat keine Zugriffsrechte auf Sensor', 1;
        RETURN
    END
    
    --IF UPDATE(ekpreis)--UPDATE sagt nur aus,ob spalte geändert wird. 
    --UPDATE liefert bei INSERT TRUE!!
    --BEGIN
     --   INSERT INTO mipo.preise(artnr,preis, typ)
     --   SELECT artnr, ekpreis, 'E'
     --   FROM inserted
    --END

    --IF UPDATE(vkpreis) --UPDATE sagt nur aus,ob spalte geändert wird.
    --BEGIN
    --     INSERT INTO mipo.preise(artnr,preis, typ)
    --    SELECT artnr, ekpreis, 'V'
     --   FROM inserted
    --END
END

 
    SELECT sg.channel_ID ,up.subscriber_ID, up.sensor_ID, up.valid_from, up.valid_to
    FROM dbo.user_permission up
    INNER JOIN dbo.sensor_group sg ON up.sensor_ID = sg.sensor_ID
    INNER JOIN dbo.subscription sp ON sp.subscriber_ID = 1

