-- ADD A NEW CHANNEL WITH SENSORS

--add a new channel with sensors with date
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @valid_from_date = '2018-11-20 00:00:00 +01:00', @valid_to_date = '2018-12-15 23:59:00 +01:00', 
                          @channel_description = 'a new one', @channel_name='default channel',@sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'

--add a new channel with sensors with default date and no channel description
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_name='bla bla',@sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'

--add a new channel with sensors with default date and no channel description
EXEC dbo.sp_prj_subscribe @subscriber_id = 2, @channel_name='bla bla',@sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'



---------------------------------------------------------------------------------------------------------------------------------------

--UPDATE CHANNEL (update valid from and valid to date)
EXEC dbo.sp_prj_subscribe @channel_id=1, @channel_name ='new', @subscriber_id = 1, @valid_from_date = '2018-11-20 11:00:00 +01:00', @valid_to_date = '2018-12-15 23:59:00 +01:00', 
                          @sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'

--UPDATE CHANNEL (update valid from and valid to date), with default date
EXEC dbo.sp_prj_subscribe @channel_id=1, @channel_name ='new', @subscriber_id = 1, @sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'

--UPDATE CHANNEL (update valid from and valid to date), with default date, without @sensor_ID_string, @sensor_ID_string_delimeter
EXEC dbo.sp_prj_subscribe @channel_id=1, @channel_name ='new', @subscriber_id = 1

--UPDATE CHANNEL (update valid from and valid to date), with default date, without @sensor_ID_string, @sensor_ID_string_delimeter, @channel_name
EXEC dbo.sp_prj_subscribe @channel_id=1, @subscriber_id = 1

------------------------------------------------------------------------------------------------------------------------------------------

--ERROR HANDLING:
--add a new channel with sensors with default date and no channel description, without sensor_ID_string_delimeter
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_name='bla bla',@sensor_ID_string='4;5;9'

--add a new channel with sensors with default date and no channel description, without sensor_ID_string_delimeter and sensor_ID_string
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_name='bla bla'

--ERRORNUMBER 50100
EXEC dbo.sp_prj_subscribe @subscriber_id = 1
--ERRORNUMBER 50101
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_id = 1,@valid_from_date = '2018-12-20 11:00:00 +01:00', @valid_to_date = '2020-12-15 23:59:00 +01:00'
--ERRORNUMBER 50102
EXEC dbo.sp_prj_subscribe @subscriber_id = 99, @channel_id = 1

--ERRORNUMBER 50104
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_id = 1,@valid_from_date = '2018-14-20 11:00:00 +01:00', @valid_to_date = '2018-12-15 23:59:00 +01:00'
--ERRORNUMBER 50105
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_id = 1,@valid_from_date = '2018-10-20 11:00:00 +01:00', @valid_to_date = '2018-13-15 23:59:00 +01:00'

--ERRORNUMBER 50106
 EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_id = 1,@valid_from_date = '2018-12-20 11:00:00 +01:00', @valid_to_date = '2018-12-15 23:59:00 +01:00'

--update channel with channel id that does not match to the subscriber channel id: ERRORNUMBER 50107
exec dbo.sp_prj_subscribe @subscriber_id = 1, @sensor_ID_string = '1,2', @sensor_ID_string_delimeter = ',', @valid_from_date = '2018-11-20 10:00:00 +01:00', @valid_to_date = '2019-2-15 23:59:00 +01:00', @channel_id = 33;

--add channel with sensor ID that does not exist: ERRORNUMBER 50108
EXEC dbo.sp_prj_subscribe @subscriber_id = 1, @channel_name='bla bla',@sensor_ID_string='4;5;99',@sensor_ID_string_delimeter=';'

--ERRORNUMBER 50300 (Trigger)
EXEC dbo.sp_prj_subscribe @subscriber_id = 2, @channel_name='bla bla',@sensor_ID_string='4;5;9',@sensor_ID_string_delimeter=';'

