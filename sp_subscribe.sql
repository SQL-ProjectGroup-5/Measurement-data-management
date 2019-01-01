
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

ALTER PROCEDURE dbo.sp_prj_subscribe
    @subscriber_id INT,
    @channel_id INT = NULL,
    @valid_from_date char(40),
    @valid_to_date char(40),
    @channel_name varchar(32) = NULL,
    @channel_description varchar(255) = NULL

AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @temp_channel_id INT

    --check if channel id IS NULL, if so, check if @channel_name and @channel_description are not null!
    IF @channel_id IS NULL AND (@channel_description IS NULL OR @channel_name IS NULL)
    BEGIN 
        SELECT 50011 AS Fehlernummer, 'Wenn keine channel_id angegeben wird duerfen channel name und channel description nicht leer sein!' AS Fehlermeldung; 
        RETURN
    END
    --check wether time difference between from- and to-date is greater 1 year
    IF DATEDIFF(MONTH,@valid_from_date,@valid_to_date) > 12
        BEGIN
            SELECT 50012 AS Fehlernummer, 'Zeitspanne zwischen from-date und to-date darf nicht groesser als 1 Jahr sein!' AS Fehlermeldung; 
            RETURN
        END

    --check if subscriber id is in db
    IF (SELECT COUNT(*) FROM dbo.subscriber WHERE (subscriber_ID = @subscriber_id)) = 0
    BEGIN
         SELECT 50012 AS Fehlernummer, 'Subscriber ID wurde nicht gefunden' AS Fehlermeldung; 
        RETURN
    END
    --check if data format and input is incorrect:
    IF TRY_CONVERT(DATETIME2,@valid_from_date) IS NULL
    BEGIN
        SELECT 50013 AS Fehlernummer, 'von Datum falsch: Format: yyyy-MM-dd hh:mm:ss +01:00' AS Fehlermeldung; 
        RETURN
    END
    ELSE IF TRY_CONVERT(DATETIME2,@valid_to_date) IS NULL
        BEGIN
        SELECT 50014 AS Fehlernummer, 'bis Datum falsch: Format: yyyy-MM-dd hh:mm:ss +01:00' AS Fehlermeldung; 
    RETURN
    END
    ELSE IF @valid_from_date>@valid_to_date
    BEGIN
        SELECT 50015 AS Fehlernummer, 'von-Datum groesser bis-Datum' AS Fehlermeldung; 
        RETURN
    END
    
    BEGIN TRY
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
            INSERT INTO dbo.channel(channel.name,channel.[description]) --DML trigger will start here due to the INSERT statement
            VALUES(@channel_name,@channel_description)
            SET @temp_channel_id = (SELECT TOP 1 channel_ID FROM dbo.channel ORDER BY channel_ID DESC) --get latest ID number 
            PRINT @temp_channel_id
            
            INSERT INTO dbo.subscription(subscription.subscriber_ID, subscription.channel_ID, subscription.valid_from, subscription.valid_to)
            VALUES(@subscriber_id, 
                @temp_channel_id,
                @valid_from_date,
                @valid_to_date)
            --testing purpose:
            SELECT * FROM dbo.subscription

        END
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS Fehlernummer, ERROR_MESSAGE() AS Fehlermeldung; -- default error
    END CATCH

END

BEGIN TRANSACTION
EXEC dbo.sp_prj_subscribe @subscriber_id = 3, @valid_from_date = '2018-11-20 00:00:00 +01:00', @valid_to_date = '2018-12-15 23:59:00 +01:00', @channel_description = 'a new one', @channel_name='bla bla'
ROLLBACK 

SELECT * FROM dbo.user_permission
SELECT * FROM dbo.subscriber

