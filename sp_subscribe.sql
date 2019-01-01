
SELECT * FROM dbo.subscriber
SELECT * FROM dbo.subscription

CREATE PROCEDURE dbo.sp_subscribe
    @subscriber_id INT,
    @channel_id INT,
    @valid_from_date char(40),
    @valid_to_date char(40),
AS
BEGIN

END