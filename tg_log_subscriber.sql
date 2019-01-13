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
		INSERT INTO dbo.logging (causing_user,involved_trigger,resulting_code,resulting_message) SELECT SUSER_NAME(), 'tg_log_subscriber',50500, 'Property of subscriber was updatet ID: ' + CAST(i.subscriber_ID AS VARCHAR) + 'name: ' + i.name FROM inserted as i;

END
