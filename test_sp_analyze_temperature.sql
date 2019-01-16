
--GET MIN MAX over time period
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2018-11-02 00:00:00 +01:00',@to_date = '2018-11-20 23:59:00 +01:00',@daily_evaluation= 0

EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2018-11-02 6:30:00 +01:00',@to_date = '2018-11-17 11:59:00 +01:00',@daily_evaluation= 0


--GET MIN MAX daily over period
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2018-11-02 00:00:00 +01:00',@to_date = '2018-11-20 23:59:00 +01:00',@daily_evaluation= 1

--choosing daily evaluation the SP turns from date time to 00:00:00 and to date time to 23:59:00 because evaluating daily can not use times between a day.
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2018-11-02 2:00:00 +01:00',@to_date = '2018-11-20 10:04:23 +01:00',@daily_evaluation= 1



--ERROR HANDLING
--Error number:
--ERRORNUMBER 50001:
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 99 ,@from_date = '2018-11-02 00:00:00 +01:00',@to_date = '2018-11-20 23:59:00 +01:00',@daily_evaluation= 1

--ERRORNUMBER 50002:
EXEC dbo.sp_analyze_temperature @subscriber_id = 2, @sensor_id = 9 ,@from_date = '2018-11-02 00:00:00 +01:00',@to_date = '2018-11-20 23:59:00 +01:00',@daily_evaluation= 1

--ERRORNUMBER 50003:
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 4 ,@from_date = '2018-11-02 00:00:00 +01:00',@to_date = '2018-11-20 23:59:00 +01:00',@daily_evaluation= 1

--ERRORNUMBER 50004: 
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2018-12-02 00:00:00 +01:00',@to_date = '2018-11-20 23:59:00 +01:00',@daily_evaluation= 1

--ERRORNUMBER 50005:
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2018-111-02 00:00:00 +01:00',@to_date = '2018-11-20 23:59:00 +01:00',@daily_evaluation= 1

--ERRORNUMBER 50006:
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2018-11-02 00:00:00 +01:00',@to_date = '2018-11-220 23:59:00 +01:00',@daily_evaluation= 1

--ERRORNUMBER 50007:
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2017-11-02 00:00:00 +01:00',@to_date = '2017-11-22 23:59:00 +01:00',@daily_evaluation= 1

--ERRORNUMBER 50008:
EXEC dbo.sp_analyze_temperature @subscriber_id = 1, @sensor_id = 5 ,@from_date = '2017-11-02 00:00:00 +01:00',@to_date = '2018-11-22 23:59:00 +01:00',@daily_evaluation= 1

