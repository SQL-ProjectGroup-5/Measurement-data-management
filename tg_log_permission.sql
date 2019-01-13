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
		INSERT INTO dbo.logging (causing_user,involved_trigger,resulting_code,resulting_message) SELECT SUSER_NAME(), 'tg_log_permission',50502, 'Property of permission was updatet ID: ' + CAST(i.permission_ID AS VARCHAR) + 'name: ' + i.name FROM inserted as i;

END