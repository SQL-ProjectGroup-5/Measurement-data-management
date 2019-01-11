/*
This is a small log trigger which is used to log events on the permission table.
The trigger uses the followig returncode, which are only written to the logging table:

-- Returncode 50502: A permission was updated
-- Returncode 50503: A new permission was inserted
*/
CREATE TRIGGER dbo.tg_log_permission_iu ON dbo.user_permission
FOR INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF (EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED))
	BEGIN
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) SELECT SUSER_NAME(), 'tg_log_permission', 50500, 'Property of permission was updated sensor ID: ' + CAST(i.sensor_ID AS VARCHAR)+ ' subscriber ID: ' + CAST(i.subscriber_ID AS VARCHAR) FROM deleted AS i;
	END ELSE IF (EXISTS (SELECT * FROM INSERTED))
	BEGIN
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) SELECT SUSER_NAME(), 'tg_log_permission', 50500, 'New permission was inserted sensor ID: ' + CAST(i.sensor_ID AS VARCHAR)+ ' subscriber ID: ' + CAST(i.subscriber_ID AS VARCHAR) FROM inserted AS i;
	END
END
