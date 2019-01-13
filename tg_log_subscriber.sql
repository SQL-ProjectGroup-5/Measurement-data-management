/*
This is a small log trigger which is used to log events on the subscriber table.
The trigger uses the followig returncode, which are only written to the logging table:

-- Returncode 50500: A subscriber was updated
-- Returncode 50501: A new subscriber was inserted
*/
CREATE TRIGGER dbo.tg_log_subscriber_iu ON dbo.subscriber
FOR INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF (EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED))
	BEGIN
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) SELECT SUSER_NAME(), 'tg_log_subscriber', 50500, 'Property of subscriber was updated ID: ' + CAST(i.subscriber_ID AS VARCHAR) FROM deleted AS i;
	END ELSE IF (EXISTS (SELECT * FROM INSERTED))
	BEGIN
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) SELECT SUSER_NAME(), 'tg_log_subscriber', 50501, 'New subscriber was inserted ID: ' + CAST(i.subscriber_ID AS VARCHAR) + ' name: ' + i.name FROM inserted AS i;
	END
END
