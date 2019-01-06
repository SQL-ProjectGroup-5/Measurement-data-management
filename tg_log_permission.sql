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
	DECLARE @sensor_id VARCHAR(32);	DECLARE @subscriber_id VARCHAR(32);
	SELECT TOP 1 @subscriber_id = subscriber_ID, @sensor_id = sensor_ID FROM INSERTED;
	IF (EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED))
	BEGIN
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(), 'tg_log_permission', 50502, 'Permission was changed subscriber_ID: ' + @subscriber_id + ' sensor_id: ' + @sensor_id);
	END ELSE IF (EXISTS (SELECT * FROM INSERTED))
	BEGIN
		INSERT INTO dbo.logging (causing_user, involved_trigger, resulting_code, resulting_message) VALUES (SUSER_NAME(), 'tg_log_permission', 50503, 'New permission added, subscriber_ID' + @subscriber_id + ' sensor_id: ' + @sensor_id);
	END
END